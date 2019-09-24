import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nautico/model/jsonModel.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'dart:math' as math;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//import 'package:nautico/CoresSensorNew.dart';
import 'package:nautico/GeoMap.dart';
//import 'package:nautico/GeoLocation.dart';
import 'package:nautico/GoogleMaps.dart';
import 'package:nautico/SharedPreferences.dart';
import 'package:nautico/ShowDataRoute.dart';
//import 'package:nautico/localStorageDataOrig.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:nautico/flutter_blue.dart';
import 'package:nautico/place_polyline.dart';
import 'package:nautico/DrawerOnly.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(new MyApp());
}


math.Random random = new math.Random();
List<double> matTemperrature = [];
List<double> matHumidity = [];
List<double> matBattery = [];

List<double> _generateRandomData(int count) {
  List<double> result = <double>[];
  for (int i = 0; i < count; i++) {
    result.add(random.nextDouble() * 100);
    print("OK");
    print("$result");
  }
  return result;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'DogHunter-IOT',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Select Device'),
    );
  }
}


class Setting extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}


class ChartShow extends StatelessWidget {
  ChartShow({Key key, this.title}) : super(key: key);
  var title;
  @override
  Widget build(BuildContext context) {
    //print("OK2");
    //print("$matTemperrature");
    //var data = matTemperrature;


    Material mychartData(String title, List Valori  , String valMin, String valMax, String imageName) {
      return Material(
          color: Colors.white,
          elevation: 14.0,
          borderRadius: BorderRadius.circular(24.0),
          shadowColor:  Color(0x802196F3),
          child: Center(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Image.asset(
                              imageName,
                              width: 30.0,
                              height: 30.0,
                              fit: BoxFit.cover,
                            ),
                            Text(" - $title", style: TextStyle(fontSize: 20.0,),),
                          ]
                        ),
                        Padding(
                          padding: EdgeInsets.all(2.0),),

                        Text("Min: $valMin - Max: $valMax",
                          style: TextStyle(fontSize: 10.0,),),


/*

                        Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Text(subtitle, style: TextStyle(fontSize: 15.0,),),
                        ),

                        Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Text("$valMin", style: TextStyle(fontSize: 30.0,),),
                        ),

                        Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Text(valMin, style: TextStyle(fontSize: 30.0,),),
                        ),
*/
                        //Chart
                        Padding(
                          padding: EdgeInsets.all(1.0),
                          child: new Sparkline(
                            data: Valori,
                            lineColor: Colors.blueAccent,
                            fillMode: FillMode.none,
                            fillColor: Colors.lightGreen[200],
                            pointsMode: PointsMode.all,
                            pointSize: 5.0,
                            pointColor: Colors.red,
                          ),
                        )
                      ],
                    )
                  ],
                )
            ),
          )
      );
    }


    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
      new Container(
        color: Colors.amberAccent,
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          StaggeredGridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              children: <Widget>[

                Padding(padding: const EdgeInsets.all(8.0),
                    child: mychartData("Temperature",matTemperrature,matTemperrature.reduce(math.min).toString() + "°C",matTemperrature.reduce(math.max).toString() + "°C",'images/temperature.png')
                ),
                Padding(padding: const EdgeInsets.all(8.0),
                    child: mychartData("Humidity",matHumidity,matHumidity.reduce(math.min).toString() + "%",matHumidity.reduce(math.max).toString() + "%",'images/humidity.png')
                ),
                Padding(padding: const EdgeInsets.all(8.0),
                    child: mychartData("Battery",matBattery,matBattery.reduce(math.min).toString() + "%",matBattery.reduce(math.max).toString() + "%",'images/battery.png')
                )
              ],
              staggeredTiles: [
                StaggeredTile.extent(4, 180.0),
                StaggeredTile.extent(4, 180.0),
                StaggeredTile.extent(4, 180.0)
              ]
          ),
        ),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  var title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}



//class DataTableWidget extends StatelessWidget {
class _MyHomePageState extends State<MyHomePage> {

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }
  BuildContext scaffoldContext;
  bool first_lap_pass = false;    //Skip first show for select device

  final String URL_DEVICE_NAME = "https://developer.linino.org/iot_sensor-coord.php?action=crea_lista_device";
  final String URL_SENSOR_VALUE = "https://developer.linino.org/iot_sensor-coord.php?action=list_json_app&limit=35&macaddress=";
  final String URL_ROUTE_LOOKUP = "https://developer.linino.org/iot_sensor-coord.php?action=get_route_lookUpAll";
  String _mySelection_name;
  String _mySelection;
  List dataDev = List(); //edited line
  List dataDevName = List(); //edited line


  //var now = new DateTime.now().add(new Duration(hours: 2));
  var now = new DateTime.now().add(new Duration(hours: 2));
  //new DateFormat('yyyy-MM-dd HH:mm:ss').format(now)
  //var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  //var yesterday = new DateTime.now().add(new Duration(days: -1));
  var yesterday = new DateTime(2019,4,10,12,30);
  //var yesterday = "2019-04-30 00:00:00";


  Future<String> getSWData() async {
    var res = await http
        .get(Uri.encodeFull(URL_DEVICE_NAME), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    debugPrint("ECCOLO ${resBody[0].toString()}");
    debugPrint("ECCOLO ${resBody[0]['Tab_01'].toString()}");
    setState(() {
      Wakelock.enable();
      dataDev = resBody;
    });
//    print("PASSATO");
//    print(resBody);
    return "Sucess";
  }

  Future<String> getSWData2() async {
    var res = await http
        .get(Uri.encodeFull(URL_ROUTE_LOOKUP), headers: {"Accept": "application/json"});
    var resBody2 = json.decode(res.body);
    debugPrint("ECCOLO ${resBody2[0].toString()}");
    debugPrint("ECCOLO ${resBody2[0]['Tab_01'].toString()}");
    return "Sucess";
  }


  void _refreshFromServer() {
    setState(() {
      _createSnackBar("Data Server Reloding ","GREEN");
      _mySelection_name =  _findNameOfSensorSelected(_mySelection);
      print("_mySelection_name: $_mySelection_name");
      //loadDataHttpDevice();
    });
  }

  String _findNameOfSensorSelected(String MacTest) {

    for (int i = 0; i < dataDev.length; i++) {
      final String MacAddress = dataDev[i]['Tab_00'].toString();
      final String DevName = dataDev[i]['Tab_01'].toString();
      print("MacAddress: $MacAddress - DevName: $DevName");

      if(MacAddress == MacTest) {
        return DevName;
      }
    }

  }
  @override
  void initState() {
    super.initState();
    this.getSWData();
    this.getSWData2();

    //dateNow();

  }

  @override
  Widget build(BuildContext context) {

    var assetImageNew = new AssetImage("images/chart_main.png");
    var imageMapButtonNew = new Image(image: assetImageNew,height: 40.0,fit: BoxFit.cover,);


    int DDB_index = 0;
    var assetImageTemp = new AssetImage('asset/temperature.png');
    var assetImageHumid = new AssetImage('asset/humidity.png');
    var assetImageTime = new AssetImage('asset/time.png');
    var imageTemp = new Image(image: assetImageTemp, width: 48.0);
    var imageHumid = new Image(image: assetImageHumid, width: 48.0);
    var imageTime = new Image(image: assetImageTime, width: 48.0);

    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text('BLE CoreSensor Suite'),
        backgroundColor: Colors.red,

/*        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.show_chart), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChartShow(title: _mySelection_name,)),
            );
            //_createSnackBar("Button Disabled ","RED");
          }),


            ew IconButton(icon: const Icon(Icons.settings), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingPreferences()),
            );
            //_createSnackBar("Button Disabled ","RED");
          }),
          new IconButton(icon: const Icon(Icons.folder_open), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShowDataRoutes()),
            );
            //_createSnackBar("Button Disabled ","RED");
          }),
            new IconButton(icon: const Icon(Icons.map), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyGeoPage()),
            );
            //_createSnackBar("Button Disabled ","RED");
          }),
          new IconButton(icon: const Icon(Icons.map),color: Colors.cyanAccent, onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GoogleMapsPage('0')),
              //MaterialPageRoute(builder: (context) => GoogleMapsPage(starterRouteMap: '3')),
              //MaterialPageRoute(builder: (context) => PlacePolylinePage()),
            );
            //_createSnackBar("Button Disabled ","RED");
          }),
          new IconButton(icon: const Icon(Icons.location_on), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyLocationPage()),
            );
            //_createSnackBar("Button Disabled ","RED");
          }),
          new IconButton(icon: const Icon(Icons.bluetooth), onPressed: () {
            //_createSnackBar("Button Disabled ","RED");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CoreSensoApp(title: "IOT BluneTooth New",)),

            );
          })
        ],*/
      ),
      drawer:  DrawerOnly(),
      floatingActionButton: _showSnackBar(),
      //hit Ctrl+space in intellij to know what are the options you can use in flutter widgets
      body:
      new Builder(builder: (BuildContext context) {
        scaffoldContext = context;
        return new
        Container(
          padding: new EdgeInsets.all(8.0),
          child: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
            new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context, showTitleActions: true,
                          onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                            setState(() {
                              yesterday = date;
                            });
                          }, currentTime: yesterday);
                    },
                    child: Text(
                      'from:\n${new DateFormat('yyyy-MM-dd HH:mm:ss').format(yesterday)}',
                      style: TextStyle(color: Colors.blue),
                    )),
                FlatButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context, showTitleActions: true,
                          onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                            setState(() {
                              now = date;
                            });
                          }, currentTime: now);
                    },

                    child: Text(
                      'to:\n${new DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}',
                      style: TextStyle(color: Colors.blue),
                    )),

                ]
            ),
                new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: new BoxDecoration(
                          borderRadius:BorderRadius.all(Radius.circular(2.0)),
                          color: Colors.white,
                        ),
                        child:
                        new DropdownButton(
                          items: dataDev.map((item) {
                            return new DropdownMenuItem(
                              child: new Text(item['Tab_00'] + ' - ' + item['Tab_01'],
                                  style: new TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14.0,
                                  )),
                              value: item['Tab_00'],
                            );
                          }).toList(),
                          hint: Text("Please choose a device"),
                          onChanged: (newVal) {
                            setState(() {
                              _mySelection = newVal;
                              _mySelection_name = dataDev[0]['Tab_01'].toString();

                              first_lap_pass = true;
                              _refreshFromServer();
                              //print("_mySelection: $_mySelection");
                              //print("_mySelection_name: $_mySelection_name");
                            });
                          },
                          value: _mySelection,
                        ),
                      ),
                      first_lap_pass == true ?
                      new Container(
                        child: IconButton(icon: const Icon(Icons.show_chart), iconSize: 50, color: Colors.pink, onPressed:() => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChartShow(title: _mySelection_name,))),
                        ),
                      ) : new Icon(Icons.check,size: 45.0 ,color: Colors.blue,)

                    ]
                ),

                first_lap_pass == true ? RowTitle : Container(),

                Container(
                  child: first_lap_pass == true ?
                  FutureBuilder(
                    future: loadDataHttp(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return body(snapshot.data);
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ) :
                  new Container(
                    padding: const EdgeInsets.fromLTRB(3.0,25,3.0,25.0),
                    decoration: new BoxDecoration(
                      color: Colors.greenAccent[50],
                    ),
                    child: Column(
                      children: <Widget>[
                        Image(image: AssetImage("images/doghunter.png",),width: 300.0,height: 300.0,fit: BoxFit.cover,),
                         Divider(),
                        Container(
                          padding: const EdgeInsets.fromLTRB(5.0,5.0,5.0,5.0),
                          decoration: new BoxDecoration(
                            color: Colors.greenAccent[50],
                          ),
                        ),
                        Text(
                          'CoreSensor Connect and Data Receiver.',
                          style: TextStyle(fontSize: 16.0, color: Colors.blue),
                        ),
                        Divider(),
                        Container(
                          padding: const EdgeInsets.fromLTRB(5.0,5.0,5.0,5.0),
                          decoration: new BoxDecoration(
                            color: Colors.greenAccent[50],
                          ),
                        ),
                        Text(
                          'Routes and Maps Management.',
                          style: TextStyle(fontSize: 16.0, color: Colors.blue),
                        ),

                      ],
                    ),
                  )


                  //
                  //new Image.asset('images/doghunter.png',width: 300.0,height: 300.0,fit: BoxFit.cover,)

                )
              ],
            ),
          ),
        );
      }),
    );
  }

  final RowTitle = Container(
      padding: EdgeInsets.all(1.0),
      child:
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Image.asset(
            'images/time.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
          Image.asset(
            'images/temperature.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
          Image.asset(
            'images/humidity.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
          Image.asset(
            'images/battery.png',
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
        ],
      )
  );


  Widget body(JsonList data) {
    return Container(
        color: Colors.white,
        child:
        Table(
            children: loadWidgetDataRows(data)
        )
    );
  }



  Future loadDataHttp() async {
    //DateFormat('yyyy-MM-dd HH:mm:ss').format(now)
    print("loadDataHttp -> _mySelection: $_mySelection");
    print("loadDataHttp -> from= ${DateFormat('yyyy-MM-dd HH:mm:ss').format(yesterday)} - to= ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}");
    http.Response response = await http.get(
        Uri.encodeFull(URL_SENSOR_VALUE + _mySelection + "&from=${DateFormat('yyyy-MM-dd HH:mm:ss').format(yesterday)}&to=${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}"),
        headers: {"Accept": "application/json"});
    print(response.body);
    String jsonString = response.body;
    final jsonResponse = json.decode(jsonString);
    JsonList ListJson = new JsonList.fromJson(jsonResponse);

    matTemperrature.clear();
    matHumidity.clear();
    matBattery.clear();

    for (int i = 0; i < ListJson.models.length; i++) {
      //print("ListJson -> ");
      //print(double.parse(ListJson.models[i].TMP));
      matTemperrature.add(double.parse(ListJson.models[i].TMP.toString()));
      matHumidity.add(double.parse(ListJson.models[i].HMD.toString()));
      matBattery.add(double.parse(ListJson.models[i].BTT.toString()));
    }

    return ListJson;
  }




  List<TableRow> loadWidgetDataRows (JsonList data) {
    List<TableRow> rows = <TableRow>[];
    rows.add(
      TableRow(
        children: [
          Text("",
            textAlign: TextAlign.center,
          ),
          Text("",
            textAlign: TextAlign.center,
          ),
          Text("",
            textAlign: TextAlign.center,
          ),
          Text("",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    for (int i = 0; i < data.models.length; i++) {

      rows.add(
        TableRow(
          decoration: new BoxDecoration(
              border: new Border (
                  bottom: BorderSide(
                      color: Colors.blueAccent,
                      width: 0.5
                  )
              )
          ),
          children: [
            Text(data.models[i].DBT.toString(),
              style: TextStyle(
                inherit: true,
                fontSize: 14.0,
                color: Colors.blueAccent,
              ),
            ),
            Text(data.models[i].TMP.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                inherit: true,
                fontSize: 16.0,
                color: Colors.deepPurple,
              ),
            ),
            Text(data.models[i].HMD.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                inherit: true,
                fontSize: 16.0,
                color: Colors.indigo,
              ),
            ),
            Text(data.models[i].BTT.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                inherit: true,
                fontSize: 16.0,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      );

    }
    return rows;
  }

  void _createSnackBar(String message, String colore) {
    final snackBar = new SnackBar(content: new Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: (colore == "RED") ? Colors.red : Colors.green);

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }

  _showSnackBar() {
    if (first_lap_pass) {
      return new FloatingActionButton(child: new Icon(Icons.refresh), onPressed: () {
        _refreshFromServer;
        _createSnackBar("Data Server Reloding ","GREEN");
      } , backgroundColor: Colors.green);
    } else {
      return new FloatingActionButton(child: new Icon(Icons.location_disabled), onPressed: (){
        _createSnackBar("Please choose a device ","RED");
        //Future.delayed(Duration(seconds: 1)).then(
        //);
      }, backgroundColor: Colors.red,);
    }
  }



}

