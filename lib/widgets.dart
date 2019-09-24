// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Text(result.device.name),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: RaisedButton(
        child: Text('CONNECT'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),
      children: <Widget>[
        _buildAdvRow(
            context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(
            context,
            'Manufacturer Data',
            getNiceManufacturerData(
                    result.advertisementData.manufacturerData) ?? 'N/A'),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A'),
      ],
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  final String CLIENT_CHARACTERISTIC_CONFIG = "00002902-0000-1000-8000-00805f9b34fb";
  final String BATTERY_MEASUREMENT = "00002a19-0000-1000-8000-00805f9b34fb";
  final String TEMPERATURE_MEASUREMENT = "00002a6e-0000-1000-8000-00805f9b34fb";
  final String HUMIDITY_MEASUREMENT = "00002a6f-0000-1000-8000-00805f9b34fb";
  final String ESS_SERVICE = "0000181a-0000-1000-8000-00805f9b34fb";
  final String BAS_SERVICE = "0000180f-0000-1000-8000-00805f9b34fb";
  final String NBS_SERVICE = "00001523-1212-efde-1523-785feabcd123";      //Nordic Blinky Service
  final String BUTTON_STATE = "00001524-1212-efde-1523-785feabcd123";     //Nordic Blinky Button
  final String LED_ONOFF = "00001525-1212-efde-1523-785feabcd123";        //Nordic Blinky Led

  const ServiceTile({Key key, this.service, this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print('service.uuid ${service.uuid.toString()}');
    //print('ESS_SERVICE $ESS_SERVICE');
    if ((service.uuid.toString() == ESS_SERVICE) || (service.uuid.toString() == BAS_SERVICE) || (service.uuid.toString() == NBS_SERVICE)) {
      print('OK passato ${service.uuid.toString()}');

      if (characteristicTiles.length > 0) {
        return new ExpansionTile(
          title: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Service'),
              new Text(
                  '0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Theme
                      .of(context)
                      .textTheme
                      .caption
                      .color))
            ],
          ),
          children: characteristicTiles,
        );
      } else {
        return new ListTile(
          title: const Text('Service'),
          subtitle: new Text(
              '0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
        );
      }
    } else {
      return new Container(width: 0.0, height: 0.0);
    }
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificastionPressed;

  static int extractInt16(final List<int> value) {
    if (value.length > 1) {
      var data = new ByteData.view(Uint8List
          .fromList(value)
          .buffer);
      //print('eccolo : ${data.toString()}');
      //return data.getFloat32(0, Endian.little);
      return data.getUint16(0, Endian.little);
    } else {
      return 0;
    }
  }

  const CharacteristicTile(
      {Key key,
      this.characteristic,
      this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificastionPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var actions = new Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new IconButton(
          icon: new Icon(
            Icons.file_download,
            color: Theme.of(context).iconTheme.color.withOpacity(0.5),
          ),
          onPressed: onReadPressed,
        ),
        new IconButton(
          icon: new Icon(Icons.file_upload,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
          onPressed: onWritePressed,
        ),
        new IconButton(
          icon: new Icon(
              characteristic.isNotifying ? Icons.sync_disabled : Icons.sync,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
          onPressed: onNotificastionPressed,
        )
      ],
    );

    var title = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Characteristic'),
        new Text(
            '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Theme.of(context).textTheme.caption.color))
      ],
    );
    if (characteristic.uuid.toString() == "00002a6e-0000-1000-8000-00805f9b34fb") {
      print("TEMPERATURE ${characteristic.uuid.toString()}");
    }

    if (characteristic.uuid.toString() == "00002a6f-0000-1000-8000-00805f9b34fb") {
      print("HUMIDITY ${characteristic.uuid.toString()}");
    }

    if (descriptorTiles.length > 0) {
      return new ExpansionTile(
        title: new ListTile(
          title: title,
          subtitle: new Text((extractInt16(characteristic.lastValue)/100).toString()),
          // subtitle: new Text("pippo"),
          contentPadding: EdgeInsets.all(0.0),
        ),
        trailing: actions,
        children: descriptorTiles,
      );
    } else {
      return new ListTile(
        title: title,
        subtitle: new Text((extractInt16(characteristic.lastValue)/100).toString()),
        //subtitle: new Text(characteristic.value.toString()),
        trailing: actions,
      );
    }
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;

  const DescriptorTile(
      {Key key, this.descriptor, this.onReadPressed, this.onWritePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Descriptor'),
        new Text(
            '0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Theme.of(context).textTheme.caption.color))
      ],
    );
    return new ListTile(
      title: title,
      subtitle: new Text(descriptor.value.toString()),
      trailing: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.file_download,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          new IconButton(
            icon: new Icon(
              Icons.file_upload,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}
