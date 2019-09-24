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
//import 'package:nautico/GoogleMaps.dart';
import 'package:nautico/SharedPreferences.dart';
import 'package:nautico/ShowDataRoute.dart';
//import 'package:nautico/localStorageDataOrig.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:nautico/flutter_blue.dart';
import 'package:nautico/place_polyline.dart';
import 'package:nautico/DrawerOnly.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/date_symbol_data_file.dart';
void main() {
  runApp(new SplashPage());
}


class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'DogHunter-IOT',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MySplashPage(title: 'Select Device'),
    );
  }
}


class MySplashPage extends StatefulWidget {
  MySplashPage({Key key, this.title}) : super(key: key);
  var title;
  @override
  _MySplashPageState createState() => _MySplashPageState();
}




//class DataTableWidget extends StatelessWidget {
class _MySplashPageState extends State<MySplashPage> {

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


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text('BLE CoreSensor Suite'),
        backgroundColor: Colors.red,
      ),
      drawer:  DrawerOnly(),

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
                Container(
                    child:
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

}

