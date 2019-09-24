import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nautico/widgets.dart';
import 'package:nautico/DrawerOnly.dart';


class CoreSensoApp extends StatefulWidget {
  CoreSensoApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CoreSensoAppState createState() => new _CoreSensoAppState();
}

class _CoreSensoAppState extends State<CoreSensoApp> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;


  @override
  void setState(fn) {
    print("PASSED-> setState.");
    if (mounted) {
      super.setState(fn);
    }
  }

  /// Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;
  bool isServicesDiscovered = false;

  /// State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice device;
  BluetoothDevice deviceCoreSensor;

  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  BluetoothService Service_NBS;


  BluetoothCharacteristic temperatureCharacteristic;
  BluetoothCharacteristic humidityCharacteristic;
  BluetoothCharacteristic batteryCharacteristic;
  BluetoothCharacteristic buttonCharacteristic;
  BluetoothCharacteristic ledCharacteristic;

  final String CLIENT_CHARACTERISTIC_CONFIG = "00002902-0000-1000-8000-00805f9b34fb";

  final String BATTERY_MEASUREMENT = "00002a19-0000-1000-8000-00805f9b34fb";
  final String TEMPERATURE_MEASUREMENT = "00002a6e-0000-1000-8000-00805f9b34fb";
  final String HUMIDITY_MEASUREMENT = "00002a6f-0000-1000-8000-00805f9b34fb";
  final String ESS_SERVICE = "0000181a-0000-1000-8000-00805f9b34fb";
  final String BAS_SERVICE = "0000180f-0000-1000-8000-00805f9b34fb";
  final String NBS_SERVICE = "00001523-1212-efde-1523-785feabcd123"; //Nordic Blinky Service
  final String BUTTON_STATE = "00001524-1212-efde-1523-785feabcd123"; //Nordic Blinky Button
  final String LED_ONOFF = "00001525-1212-efde-1523-785feabcd123"; //Nordic Blinky Led

  int batteryValue = 0;
  double temperatureValue = 0;
  double humidityValue = 0;
  int buttonValue = 0;
  bool ledValue = false;


  double extractDouble(final List<int> value) {
    var data = new ByteData.view(Uint8List
        .fromList(value)
        .buffer);
    return data.getFloat32(0, Endian.little);
  }

  int extractInt16(final List<int> value) {
    var data = new ByteData.view(Uint8List
        .fromList(value)
        .buffer);
    //return data.getFloat32(0, Endian.little);
    return data.getUint16(0, Endian.little);
  }

  int extractUnit8(final List<int> value) {
    var data = new ByteData.view(Uint8List
        .fromList(value)
        .buffer);
    //return data.getFloat32(0, Endian.little);
    return data.getUint8(0);
  }

  @override
  void initState() {
    super.initState();
// Immediately get the state of FlutterBlue
//    _flutterBlue.state.then((s) {
//      setState(() {
//        state = s;
//      });
//    });
// Subscribe to state changes
//    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
    _stateSubscription = _flutterBlue.state.listen((s) {
      setState(() {
        state = s;
      });
    });
    _startScan();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    super.dispose();
  }

  _startScan() {
    _scanSubscription = _flutterBlue
        .scan(timeout: const Duration(seconds: 4),
    ).listen((scanResult) {
      print('localName: ${scanResult.advertisementData.localName}');
      print(
          'manufacturerData: ${scanResult.advertisementData.manufacturerData}');
      print('serviceData: ${scanResult.advertisementData.serviceData}');
/*
          setState(() {
            scanResults[scanResult.device.id] = scanResult;
          });
        */
      if (scanResult.advertisementData.localName == "CoreSensor") {
        //setState(() {
        scanResults[scanResult.device.id] = scanResult;
        deviceCoreSensor = scanResults[scanResult.device.id].device;
        _stopScanNew();
        print('TROVATO');
        //});
        _connect(deviceCoreSensor);
//        _connect(scanResults[scanResult.device.id].device);
        print('PASSED-> _connect(device)');
      }

      //}, onDone: _stopScanAndStart(deviceCoreSensor));  //}, onDone: _stopScan);
    }, onDone: _stopScanNew);
/*
      if(deviceCoreSensor.toString().length < 8) {
        _connect(deviceCoreSensor);
      }

      setState(() {
        isScanning = true;
      });
*/

  }

/*
  _stopScanAndStart(BluetoothDevice dev) {
    //setState(() {
      _stopScan();
      _connect(dev);
    //});
  }*/
  _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      isScanning = false;
    });
  }

  _stopScanNew() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  _connect(BluetoothDevice d) async {
    device = d;
    await device.connect();
/*

// Connect to device
    deviceConnection = _flutterBlue
        .connect(device, timeout: const Duration(seconds: 4))
        .listen(
      null,
      onDone: _disconnect,
    );
*/

// Update the connection state immediately
    try {
      var then = device.state.listen((s) {
        setState(() {
          deviceState = s;
        });
      });
    } on Exception catch (e) {
      print('error caught: $e');
    }
// Subscribe to connection changes
    //deviceStateSubscription = device.onStateChanged().listen((s) {
    deviceStateSubscription = device.state.listen((s) {
      setState(() {
        deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        device.discoverServices().then((s) {
          setState(() {
            services = s;
            print(
                'PASSED-> _connect: device.discoverServices: services.length: ${services
                    .length}');
            //_buildServiceTilesNew(services);
            //isServicesDiscovered = true;
            Future.delayed(new Duration(seconds: 4), () {
              _buildServiceTilesNew(services);
            });
          });
        });
      }
    });
  }

  _buildServiceTilesNew(List<BluetoothService> services) {
    //Search Services and chose characteritics
    print('PASSED-> _buildServiceTilesNew: services.length: ${services
        .length}');

    services.forEach((service) {
      if (service.uuid.toString() ==
          ESS_SERVICE) { //Enviroment Senso service Temp./Humy.
        print('PASSED-> _findSevice: service.uuid.toString: ${service.uuid
            .toString()}');
        service.characteristics.forEach((val) {
          if (val.uuid.toString() == HUMIDITY_MEASUREMENT) {
            print('PASSED-> _findSevice: val.uuid.toString: ${val.uuid
                .toString()}');
            humidityCharacteristic = val;
          }
          if (val.uuid.toString() == TEMPERATURE_MEASUREMENT) {
            print('PASSED-> _findSevice: val.uuid.toString: ${val.uuid
                .toString()}');
            temperatureCharacteristic = val;
            //_setNotification(val);
          }
        });
      }
    });
    // SET notification for Temperature and with delay Humidity
    _setNotification(humidityCharacteristic, true);

    Future.delayed(new Duration(seconds: 1), () {
      _setNotification(temperatureCharacteristic, true);
      //print(' PASSATO _readCharacteristicDelay: ${c.uuid.toString()}');
      //_readCharacteristicNew(c);
    });
    //-----------------------------------------------------------------------------

    //Serch services
    Future.delayed(const Duration(seconds: 4), () {
      print("OK Future.delayed");
      services.forEach((service) {
        if (service.uuid.toString() == BAS_SERVICE) { //Battery Service
          print('PASSED-> _findSevice: service.uuid.toString: ${service.uuid
              .toString()}');
          service.characteristics.forEach((val) {
            if (val.uuid.toString() == BATTERY_MEASUREMENT) {
              print('PASSED-> _findSevice: val.uuid.toString: ${val.uuid
                  .toString()}');
              batteryCharacteristic = val;
            }
          });
        }
      });
      // SET notification for battery
      Future.delayed(new Duration(seconds: 1), () {
        _setNotification(batteryCharacteristic, true);
        //print(' PASSATO _readCharacteristicDelay: ${c.uuid.toString()}');
        //_readCharacteristicNew(c);
      });
    });
    //----------------------------------------------------------------------------


    //Serch services
    Future.delayed(const Duration(seconds: 8), () {
      print("OK Future.delayed");
      services.forEach((service) {
        if (service.uuid.toString() == NBS_SERVICE) { //Nordic Blink Service
          print('PASSED-> _findSevice: service.uuid.toString: ${service.uuid
              .toString()}');
          service.characteristics.forEach((val) {
            if (val.uuid.toString() == BUTTON_STATE) {
              print('PASSED-> _findSevice: val.uuid.toString: ${val.uuid
                  .toString()}');
              buttonCharacteristic = val;
            }
            if (val.uuid.toString() == LED_ONOFF) {
              print('PASSED-> _findSevice: val.uuid.toString: ${val.uuid
                  .toString()}');
              ledCharacteristic = val;
            }
          });
        }
      });
      // SET notification for button
      Future.delayed(new Duration(seconds: 1), () {
        _setNotification(buttonCharacteristic, true);
        //print(' PASSATO _readCharacteristicDelay: ${c.uuid.toString()}');
        //_readCharacteristicNew(c);
      });

      // SET notification for LED
      Future.delayed(new Duration(seconds: 4), () {
        _readCharacteristicLed(ledCharacteristic);
        //print(' PASSATO _readCharacteristicDelay: ${c.uuid.toString()}');
        //_readCharacteristicNew(c);
      });
    });
    //----------------------------------------------------------------------------
    isServicesDiscovered = true;
  }
  _disconnect() {
// Remove all value changed listeners
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    setState(() {
      device = null;
    });
  }

/*

  _readCharacteristic(BluetoothCharacteristic c) async {
    await device.readCharacteristic(c);
    print('PASSED-> _readCharacteristic: c.toString: ${c.toString()}');
    print('PASSED-> _readCharacteristic: c.value: ${c.value}');

    //_setNotification(c);
    setState(() {});
  }
*/

  _readCharacteristicLed(BluetoothCharacteristic c) async {
    await c.read();
    print('PASSED-> _readCharacteristicLed: c.value: ${c.value}');
    int test = extractUnit8(await c.read()) ;
    print('PASSED-> _readCharacteristicLed: test: ${test.toString()}');
    ledValue = (test > 0) ? true : false;
    //_setNotification(c);
    setState(() {});
  }

  _writeCharacteristic(BluetoothCharacteristic c) async {
    await c.write([0x12, 0x34]);
//    await device.writeCharacteristic(c, [0x12, 0x34],
//        type: CharacteristicWriteType.withResponse);
    setState(() {});
  }

  _writeCharacteristicLed(BluetoothCharacteristic c) async {
    await c.write(((ledValue) ? [0x00] : [0x01]));
//    await device.writeCharacteristic(c, ((ledValue) ? [0x00] : [0x01]),
//        type: CharacteristicWriteType.withResponse);

    _readCharacteristicLed(c);
    setState(() {});
  }

  _readDescriptor(BluetoothDescriptor d) async {
    //await device.readDescriptor(d);
    List<int> value = await d.read();
    setState(() {});
  }

  _writeDescriptor(BluetoothDescriptor d) async {
    await d.write([0x12, 0x34]);
    //await device.writeDescriptor(d, [0x12, 0x34]);
    setState(() {});
  }

  _setNotification(BluetoothCharacteristic c, bool testDescriptor) async {
/*
    if (c.isNotifying) {
      await c.setNotifyValue(false);

      //await device.setNotifyValue(c, false);
// Cancel subscription
      valueChangedSubscriptions[c.uuid]?.cancel();
      valueChangedSubscriptions.remove(c.uuid);
    } else {
      await c.setNotifyValue(true);
      final sub = c.value.listen((d) {
        setState(() {
          print('onValueChangedx $d');
        });
      });
*/


    if (c.isNotifying) {
      await c.setNotifyValue(false);
      // Cancel subscription
      valueChangedSubscriptions[c.uuid]?.cancel();
      valueChangedSubscriptions.remove(c.uuid);
    } else {
      await c.setNotifyValue(true);
      // ignore: cancel_subscriptions

      if (c.uuid.toString() == HUMIDITY_MEASUREMENT) {
        final sub1 = c.value.listen((d) {
          // ignore: cancel_subscriptions
          print('onValueChangedx HUMIDITY_MEASUREMENT - uuid: ${c.uuid
              .toString()}');
          var test = extractInt16(d) / 100;
          print('onValueChangedx extractInt16: $test');
          //var test = d;
          //print('onValueChangedx value d: $test');
          setState(() {
            humidityValue = test;
          });
        });
    // Add to map
        valueChangedSubscriptions[c.uuid] = sub1;
      }
    // ignore: cancel_subscriptions
      if (c.uuid.toString() == TEMPERATURE_MEASUREMENT) {
        final sub2 = c.value.listen((d) {
          //print('onValueChangedx $d');
          print('onValueChangedx TEMPERATURE_MEASUREMENT - uuid: ${c.uuid
              .toString()}');
          var test = extractInt16(d) / 100;
          print('onValueChangedx extractInt16: $test');
          //var test = d;
          //print('onValueChangedx value d: $test');
          setState(() {
            temperatureValue = test;
          });
        });
    // Add to map
        valueChangedSubscriptions[c.uuid] = sub2;
      }

      if (c.uuid.toString() == BATTERY_MEASUREMENT) {
        final sub3 = c.value.listen((d) {
          //print('onValueChangedx $d');
          print('onValueChangedx BATTERY_MEASUREMENT - uuid: ${c.uuid
              .toString()}');
          var test = extractUnit8(d);
          print('onValueChangedx extractUnit8: $test');
          //var test = d;
          //print('onValueChangedx value d: $test');
          setState(() {
            batteryValue = test;
          });
        });
    // Add to map
        valueChangedSubscriptions[c.uuid] = sub3;
      }

      if (c.uuid.toString() == BUTTON_STATE) {
        final sub4 = c.value.listen((d) {
            print('onValueChangedx button $d');
            print(
                'onValueChangedx BUTTON_STATE - uuid: ${c.uuid.toString()}');
            var test = extractUnit8(d);
            print('onValueChangedx extractUnit8: $test');
            //var test = d;
            //print('onValueChangedx value d: $test');
            setState(() {
              buttonValue = test;
            });
          });
    // Add to map
        valueChangedSubscriptions[c.uuid] = sub4;
      }

      if (c.uuid.toString() == LED_ONOFF) {
        final sub5 = c.value.listen((d) {
            print('onValueChangedx button $d');
            print('onValueChangedx LED_ONOFF - uuid: ${c.uuid.toString()}');
            var test = extractUnit8(d);
            print('onValueChangedx extractUnit8: $test');
            //var test = d;
            //print('onValueChangedx value d: $test');
            setState(() {
              ledValue = (test > 0) ? true : false;
            });
          });
    // Add to map
        valueChangedSubscriptions[c.uuid] = sub5;
      }
    }
    setState(() {});
    //    }
  }

    _refreshDeviceState(BluetoothDevice d) async {
      var state = await d.state;
      setState(() {
        deviceState = state as BluetoothDeviceState;
        print('State refreshed: $deviceState');
      });
    }

    _buildScanningButton() {
      if (isConnected || state != BluetoothState.on) {
        return null;
      }
      if (isScanning) {
        return new FloatingActionButton(
          child: new Icon(Icons.stop),
          onPressed: _stopScan,
          backgroundColor: Colors.red,
        );
      } else {
        return new FloatingActionButton(
            child: new Icon(Icons.search), onPressed: _startScan);
      }
    }

    _buildScanResultTiles() {
      return scanResults.values
          .map((r) =>
          ScanResultTile(
            result: r,
            //onTap: () => _connect(r.device),
            onTap: () {
              _connect(r.device);
              //print("ECCOLO");
              print(r.device);
            },
          )
      )
          .toList();
    }

/*
  List<Widget> _buildServiceTiles() {
    return services
    .map(
      (s) => new ServiceTile(
        service: s,
        characteristicTiles: s.characteristics
        .map(
          (c) => new CharacteristicTile(
            characteristic: c,
            onReadPressed: () => _readCharacteristic(c),
            onWritePressed: () => _writeCharacteristic(c),
            onNotificastionPressed: () => _setNotification(c,true),
            descriptorTiles: c.descriptors
            .map(
              (d) => new DescriptorTile(
                descriptor: d,
                onReadPressed: () => _readDescriptor(d),
                onWritePressed: () => _writeDescriptor(d),
              ),
            )
            .toList(),
          ),
        )
        .toList(),
      ),
    )
    .toList();
  }
*/

    _buildActionButtons() {
      if (isConnected) {
        return <Widget>[
          new IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () => _disconnect(),
          ),
          new IconButton(icon: const Icon(Icons.home), onPressed: () {
            Navigator.pop(context);
            //Navigator.push(context,MaterialPageRoute(builder: (context) => ChartShow(title: _mySelection_name,)),);
            //_createSnackBar("Button Disabled ","RED");
          }),
        ];
      } else {
        return <Widget>[
          new IconButton(icon: const Icon(Icons.home), onPressed: () {
            Navigator.pop(context);
            //Navigator.push(context,MaterialPageRoute(builder: (context) => ChartShow(title: _mySelection_name,)),);
            //_createSnackBar("Button Disabled ","RED");
          }),
        ];
      }
    }

    _buildAlertTile() {
      return new Container(
        color: Colors.redAccent,
        child: new ListTile(
          title: new Text(
            'Bluetooth adapter is ${state.toString().substring(15)}',
            style: Theme
                .of(context)
                .primaryTextTheme
                .subhead,
          ),
          trailing: new Icon(
            Icons.error,
            color: Theme
                .of(context)
                .primaryTextTheme
                .subhead
                .color,
          ),
        ),
      );
    }

    _buildDeviceStateTile() {
      return new ListTile(
          leading: (deviceState == BluetoothDeviceState.connected)
              ? Image.asset('images/CoreIcon.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,)
              : const Icon(Icons.bluetooth_disabled),
          title: new Text(
              'CoreSensor is ${deviceState.toString().split('.')[1]}.'),
          subtitle: new Text('${device.id}'),
          trailing: new IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDeviceState(device),
            color: Theme
                .of(context)
                .iconTheme
                .color
                .withOpacity(0.5),
          ));
    }

    _buildResultSensorTileTemperature() {
      return new ListTile(
        leading: (isServicesDiscovered)
            ? Image.asset('images/temperature.png',
          width: 40.0,
          height: 40.0,
          fit: BoxFit.cover,
        )
            : const Icon(Icons.bluetooth_disabled),
        title: new Text('${temperatureValue.toString()}'),
        //new Text('Device is ${deviceState.toString().split('.')[1]}.'),
        subtitle: new Text('Temperature'),
/*
        trailing: new IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshDeviceState(device),
          color: Theme.of(context).iconTheme.color.withOpacity(0.5),
        )
*/
      );
    }

    _buildResultSensorTileHumydity() {
      return new ListTile(
        leading: (isServicesDiscovered)
            ? Image.asset('images/humidity.png',
          width: 40.0,
          height: 40.0,
          fit: BoxFit.cover,
        )
            : const Icon(Icons.bluetooth_disabled),
        title: new Text('${humidityValue.toString()}'),
        //new Text('Device is ${deviceState.toString().split('.')[1]}.'),
        subtitle: new Text('Humidity'),
/*
        trailing: new IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshDeviceState(device),
          color: Theme.of(context).iconTheme.color.withOpacity(0.5),
        )
*/
      );
    }

    _buildResultSensorTileBattery() {
      return Center(
        child: new ListTile(
          leading: (isServicesDiscovered)
              ? Image.asset('images/battery.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          )
              : const Icon(Icons.bluetooth_disabled),
          title: new Text('${batteryValue.toString()}'),
          //new Text('Device is ${deviceState.toString().split('.')[1]}.'),
          subtitle: new Text('Battery'),
/*
          trailing: new IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDeviceState(device),
            color: Theme.of(context).iconTheme.color.withOpacity(0.5),
          )
*/
        ),
      );
    }

    _buildResultSensorTileButton() {
      return Center(
        child: new ListTile(
          leading: (isServicesDiscovered)
              ? Image.asset('images/button_locked.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          )
              : const Icon(Icons.bluetooth_disabled),
          title: (buttonValue == 1) ? new Text('PRESSED') : new Text('HOLD'),
          //new Text('Device is ${deviceState.toString().split('.')[1]}.'),
          subtitle: new Text('Button'),
/*
          trailing: new IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDeviceState(device),
            color: Theme.of(context).iconTheme.color.withOpacity(0.5),
          )
*/
        ),
      );
    }

    _buildResultSensorTileLed() {
      return Center(
        child: new ListTile(
          leading: (isServicesDiscovered)
              ?
          ((ledValue) ? Image.asset('images/led_on.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          )
              : Image.asset('images/led_off.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ))
              : const Icon(Icons.bluetooth_disabled),

          title: new RaisedButton(
              onPressed: () => _writeCharacteristicLed(ledCharacteristic)),

          /*new IconButton(
          icon: new Icon(
              ledValue ? Icons.highlight : Icons.highlight_off,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
          onPressed:  () => _writeCharacteristicLed(ledCharacteristic),
        )*/
          //new RaisedButton(onPressed: () => _writeCharacteristicLed(ledCharacteristic)),
/*        subtitle: new Switch(
              onChanged: (bool value) {
                setState(() => this.ledValue = value);
              },
          value: this.ledValue,
        ),*/
/*
          trailing: new IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDeviceState(device),
            color: Theme.of(context).iconTheme.color.withOpacity(0.5),
          )
*/
        ),
      );
    }


    _buildProgressBarTile() {
      return new LinearProgressIndicator();
    }

    @override
    Widget build(BuildContext context) {
      var tiles = new List<Widget>();
      if (state != BluetoothState.on) {
        tiles.add(_buildAlertTile());
      }
      if (isConnected) {
        print('PASSED-> build: isConnected: $isConnected');
        tiles.add(_buildDeviceStateTile());
        //_buildServiceTilesNew(services);
        //tiles.addAll(_buildServiceTiles());
        tiles.add(_buildResultSensorTileTemperature());
        tiles.add(_buildResultSensorTileHumydity());
        tiles.add(_buildResultSensorTileBattery());
        tiles.add(_buildResultSensorTileButton());
        tiles.add(_buildResultSensorTileLed());
      } else {
        tiles.addAll(_buildScanResultTiles());
      }
      return new MaterialApp(
        home: new Scaffold(

          appBar: new AppBar(
            title: new Text("IOT BlueTooth Connection"),
            backgroundColor: Colors.red,
          ),
          drawer: DrawerOnly(),

          floatingActionButton: _buildScanningButton(),
          body: new Stack(
            children: <Widget>[
              (isScanning) ? _buildProgressBarTile() : Container(),
              new ListView(
                children: tiles,
              )
            ],
          ),
        ),
      );
    }



}