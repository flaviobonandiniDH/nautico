import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nautico/model/jsonModel.dart';
import 'package:nautico/model/jsonModelRouteLookUp.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'dart:math' as math;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//import 'package:nautico/CoresSensorNew.dart';
import 'package:nautico/GeoMap.dart';
//import 'package:nautico/GeoLocation.dart';
import 'package:nautico/GoogleMaps.dart';
import 'package:nautico/SharedPreferences.dart';
import 'package:nautico/localStorageData.dart';
//import 'package:nautico/localStorageDataOrig.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:nautico/flutter_blue.dart';
import 'package:nautico/place_polyline.dart';


import 'package:flutter/material.dart';
import 'package:nautico/model/RoutesModelDB.dart';
import 'package:nautico/model/jsonModelRoute.dart';
import 'package:nautico/model/Database.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:nautico/DrawerOnly.dart';

import 'dart:math' as math;

//void main() => runApp(MaterialApp(home: MyApp()));

class ShowDataRoutes extends StatefulWidget {

  @override
  _ShowDataRoutesState createState() => _ShowDataRoutesState();
}

class _ShowDataRoutesState extends State<ShowDataRoutes> {

  BuildContext scaffoldContext;
  bool first_lap_pass = false;    //Skip first show for select device

  final String URL_ROUTE_COORD = "https://developer.linino.org/iot_sensor-coord.php?action=list_json_coord&id_route=";
  final String URL_ROUTE_LOOKUP = "https://developer.linino.org/iot_sensor-coord.php?action=get_route_lookUpAll";
  
  JsonListRoute ListJson;

 // final String url = "https://developer.linino.org/iot_sensor-test.php?action=crea_lista_device";
  String _mySelection_name;
  String _mySelection_description;
  String _mySelection;
  List dataDev = List(); //edited line
  List dataDevName = List(); //edited line

  

  String NameRoute;
  String DescriptionRoute;

  Future<String> getSWData() async {
    var res = await http
        .get(Uri.encodeFull(URL_ROUTE_LOOKUP), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    //debugPrint("ECCOLO ${resBody[0].toString()}");
    //debugPrint("ECCOLO ${resBody[0]['Tab_01'].toString()}");
    setState(() {
      dataDev = resBody;
    });
//    print("PASSATO");
//    print(resBody);
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    //this.loadDataHttpLookUpAll();
    this.getSWData();
    //DBProvider.db.DropTable("main.Iot_Routes_Tracker");
    //this.loadDataHttpRoute(numRoute);
    //this.getRoutePoints();
  }

  @override
  void setState(fn) {
    print("PASSED-> setState.");
    if (mounted) {
      super.setState(fn);
    }
  }


  Future loadDataHttpRoute(String nRoute) async {
    String urlRouteNumber = URL_ROUTE_COORD + nRoute.toString();
    http.Response response = await http.get(
        Uri.encodeFull(urlRouteNumber),
        headers: {"Accept": "application/json"});
    //print('HTTP-loadDataHttpRoute ${response.body}');
    String jsonString = response.body;
    final jsonResponse = json.decode(jsonString);
    ListJson = new JsonListRoute.fromJson(jsonResponse);
    print('HTTP-loadDataHttpRoute ${jsonResponse}');

    // routePoints.clear();

    for (int i = 0; i < jsonResponse.length; i++) {
      //await DBProvider.db.newRouteRowJson(ListJson.models[i]);
      debugPrint(
          "ListJson.models[i] : ${ListJson.models[i].IDR} - ${ListJson.models[i]
              .LAT} - ${ListJson.models[i].LNG} - ${ListJson.models[i].TEV}");
    }

    return ListJson;
/*

    setState(() {
      //
    });
*/
  }

  void _saveLocalRoute(String numRoute) {
      print("numRoute: $numRoute");
  }


  Future loadDataHttpLookUpAll() async {
    String urlRouteNumber = URL_ROUTE_LOOKUP;
    http.Response response = await http.get(
        Uri.encodeFull(urlRouteNumber),
        headers: {"Accept": "application/json"});
    //print('HTTP-loadDataHttpRoute ${response.body}');
    String jsonString = response.body;
    //print('HTTP-jsonString ${jsonString}');
    final jsonResponseLookUp = json.decode(jsonString);
    // ignore: non_constant_identifier_names
    JsonListRouteLookUp ListJsonLookUp;
    ListJsonLookUp = new JsonListRouteLookUp.fromJson(jsonResponseLookUp);
    //print('HTTP-loadDataHttpLookUplength ${ListJsonLookUp.modelsLookUp.length}');

    for (int i = 0; i < ListJsonLookUp.modelsLookUp.length; i++) {
      NameRoute = ListJsonLookUp.modelsLookUp[i].NAM;
      DescriptionRoute = ListJsonLookUp.modelsLookUp[i].DES;
      debugPrint("ListJsonLookUp.models: ${ListJsonLookUp.modelsLookUp[i].NAM}");
    }

    return ListJsonLookUp;
/*    setState(() {
      //dataDev = ListJsonLookUp;
    });*/
  }

  @override
  Widget build(BuildContext context) {

    var assetImage = new AssetImage("images/sea_map.png");
    var imageMapButton = new Image(image: assetImage, height: 40.0, width: 100.0,fit: BoxFit.cover,);

    var assetImageLogo = new AssetImage("images/sea_map.png");
    var imageMapLogo = new Image(image: assetImageLogo, height: 150.0, width: 150.0,fit: BoxFit.cover,);

    return new Scaffold(
      backgroundColor: Colors.white,

      appBar: new AppBar(
        title: new Text("Show Data Routes"),
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
                              child: new Text(item['Tab_01'],
                                  style: new TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14.0,
                                  )),
                              value: item['Tab_00'],
                            );
                          }).toList(),
                          hint: Text("Please choose a Route"),
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
                        height: imageMapButton.height,
                        width: imageMapButton.width,
                        child: new FlatButton(
                          onPressed:() => Navigator.of(context).push(MaterialPageRoute(builder: (context) => GoogleMapsPage(_mySelection))),
                          child: new ConstrainedBox(
                            constraints: new BoxConstraints.expand(),
                            child: imageMapButton,
                          ),
                        ),
                      ) : new Icon(Icons.check,size: 45.0 ,color: Colors.blue,)
/*
                      first_lap_pass == true ?
                      new Container(
                          child: ConstrainedBox(
                            constraints: BoxConstraints.expand(),
                            child: FlatButton(onPressed: null,
                              child: Image.asset('images/sea_map.png',width: 40.0,height: 40.0,fit: BoxFit.cover,)
                            )
                          )
                      ) : new Container()
*/
                    ]
                ),

                first_lap_pass == true ?
                new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15.0,3.0,3.0,15.0),
                          decoration: new BoxDecoration(
                            color: Colors.yellow[50],
                          ),
                          child:  first_lap_pass ?
                          new Text("$_mySelection_description") :
                          new Container(),

                        ),
                      ),
                    ]
                ) : Container(),

                first_lap_pass == true ? RowTitle : Container(),

                Container(
                  child: first_lap_pass == true ?
                  FutureBuilder(
                    future: loadDataHttpRoute(_mySelection),
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
                          imageMapLogo,
                          Divider(),
                          Text(
                            'Chose your route from DB Server to show GPS coordinates.',
                            style: TextStyle(fontSize: 16.0, color: Colors.blue),
                          ),
                          Divider(),
                          Text(
                            'Select a pair of coordinates to display the position on the map',
                            style: TextStyle(fontSize: 16.0, color: Colors.blue),
                          ),
                          Divider(),
                          Text(
                            'Click on the map icon when it appears after selecting a route',
                            style: TextStyle(fontSize: 16.0, color: Colors.blue),
                          ),
                        ],
                      ),
                  )

                ),
              ],
            ),
          ),
        );
      }),
    );
  }



  final RowTitle = Container(
      padding: EdgeInsets.all(1.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text("TIME",
            style: TextStyle(
              inherit: true,
              fontSize: 16.0,
              color: Colors.blueAccent,
            ),
          ),
          Text("LAT.",
            style: TextStyle(
              inherit: true,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          Text("LNG.",
            style: TextStyle(
              inherit: true,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          Text("ALT.",
            style: TextStyle(
              inherit: true,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
        ],
      )
  );


  Widget body(JsonListRoute data) {
    return Container(
        color: Colors.white,
        child:
        Table(
            children: loadWidgetDataRows(data)
        )
    );
  }

  List<TableRow> loadWidgetDataRows (JsonListRoute data) {
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
            Text(data.models[i].TEV.toString(),
              style: TextStyle(
                inherit: true,
                fontSize: 14.0,
                color: Colors.blueAccent,
              ),
            ),
            Text(data.models[i].LAT.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                inherit: true,
                fontSize: 16.0,
                color: Colors.deepPurple,
              ),
            ),
            Text(data.models[i].LNG.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                inherit: true,
                fontSize: 16.0,
                color: Colors.indigo,
              ),
            ),
            Text(data.models[i].IDR.toString(),
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

  void _refreshFromServer() {
    setState(() {
      _createSnackBar("Data Server Reloding ","GREEN");

      setState(() {
        _mySelection_description = _findDescRouteSelected(_mySelection);
      });

      //print("_mySelection_name: $_mySelection_name");
      //loadDataHttpDevice();
    });
  }

  String _findDescRouteSelected(String idTest) {

    for (int i = 0; i < dataDev.length; i++) {
      final String nameSel = dataDev[i]['Tab_01'].toString();
      final String descSel = dataDev[i]['Tab_02'].toString();
      final String numRouteSel = dataDev[i]['Tab_00'];
      print("numRouteSel: $numRouteSel - nameSel: $nameSel");

      if(numRouteSel == idTest) {
        return descSel;
      }
    }

  }

}