import 'package:flutter/material.dart';
import 'package:nautico/model/RoutesModelDB.dart';
import 'package:nautico/model/jsonModelRoute.dart';
import 'package:nautico/model/jsonModelRouteLookUp.dart';
import 'package:nautico/model/Database.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'dart:math' as math;

//void main() => runApp(MaterialApp(home: MyApp()));

class LocalStorage extends StatefulWidget {
  @override
  _LocalStorageState createState() => _LocalStorageState();
}

class _LocalStorageState extends State<LocalStorage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext scaffoldContext;

  int numRoute = 1;

  final String URL_ROUTE_COORD = "https://developer.linino.org/iot_sensor-coord.php?action=list_json_coord&id_route=";
  final String URL_ROUTE_LOOKUP = "https://developer.linino.org/iot_sensor-coord.php?action=get_route_lookUp&id_route=";
  final String URL_ROUTE_LOOKUP_ALL = "https://developer.linino.org/iot_sensor-coord.php?action=get_route_lookUpAll";

  JsonListRoute ListJson;

  String timeStartRoute;
  String timeStopRoute;

  String _mySelection_name;
  String _mySelection_description;
  String _mySelection;

  String NameRoute;
  String DescriptionRoute;
  List dataDev = List(); //edited line


  @override
  void initState() {
    super.initState();
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

  Future<String> getSWData() async {
    var res = await http
        .get(Uri.encodeFull(URL_ROUTE_LOOKUP_ALL), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    //debugPrint("ECCOLO ${resBody[0].toString()}");
    //debugPrint("ECCOLO ${resBody[0]['Tab_01'].toString()}");
    setState(() {
      dataDev = resBody;
    });
    print("PASSATO resBody");
    print(resBody);
    return "Success";
  }




  Future loadDataHttpLookUp(int nRoute) async {
    String urlRouteNumber = URL_ROUTE_LOOKUP + nRoute.toString();
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

    NameRoute = ListJsonLookUp.modelsLookUp[0].NAM;
    DescriptionRoute = ListJsonLookUp.modelsLookUp[0].DES;
    print('NameRoute $NameRoute');
    print('DescriptionRoute  $DescriptionRoute');
    debugPrint("ListJsonLookUp.models: ${ListJsonLookUp.modelsLookUp[0].NAM}");

    setState(() {
      //
    });
  }

  Future loadDataHttpRoute(int nRoute) async {
    String urlRouteNumber = URL_ROUTE_COORD + nRoute.toString();
    http.Response response = await http.get(
        Uri.encodeFull(urlRouteNumber),
        headers: {"Accept": "application/json"});
    //print('HTTP-loadDataHttpRoute ${response.body}');
    String jsonString = response.body;
    final jsonResponse = json.decode(jsonString);
    ListJson = new JsonListRoute.fromJson(jsonResponse);
    print('HTTP-loadDataHttpRoute ${jsonResponse}');

    await DBProvider.db.newRouteRowJson(ListJson);
    // routePoints.clear();

/*
    for (int i = 0; i < jsonResponse.length; i++) {
      await DBProvider.db.newRouteRowJson(ListJson.models[i]);
      debugPrint(
          "ListJson.models[i] : ${ListJson.models[i].IDR} - ${ListJson.models[i]
              .LAT} - ${ListJson.models[i].LNG} - ${ListJson.models[i].TEV}");
    }
*/

    setState(() {
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Routes Management")),

        body: new Builder(builder: (BuildContext context) {
          scaffoldContext = context;
          return new Padding(
            padding: EdgeInsets.only(left: 2.0),
            child: Column(
              children: [

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

                              //first_lap_pass = true;
                              //_refreshFromServer();
                              //print("_mySelection: $_mySelection");
                              //print("_mySelection_name: $_mySelection_name");
                            });
                          },
                          value: _mySelection,
                        ),
                      ),
                    ]
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.5, bottom: 0.5),
                  child: Row(
                    children: <Widget>[
                      MaterialButton(
                        child: Text('Load R.2'),
                        onPressed: () {
                          //loadDataHttpRoute(2);

                        },
                      ),
                      MaterialButton(
                        child: Text('Delete All'),
                        onPressed: () {
                          print('Delete All');
                          //DBProvider.db.deleteAll();
                        },
                      ),

                      MaterialButton(
                        child: Text('Count Row'),
                        onPressed: () {
                          DBProvider.db.countRow();
                        },
                      ),
                     ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.5, bottom: 0.5),
                  child: Row(
                    children: <Widget>[
                      MaterialButton(
                        child: Text('Load R.2'),
                        onPressed: () {
                          //loadDataHttpRoute(2);

                        },
                      ),
                      MaterialButton(
                        child: Text('Delete All'),
                        onPressed: () {
                          print('Delete All');
                          //DBProvider.db.deleteAll();
                        },
                      ),

                      MaterialButton(
                        child: Text('Count Row'),
                        onPressed: () {
                          DBProvider.db.countRow();
                        },
                      ),
                    ],
                  ),
                ),

                //-----
                Flexible(
                  child: FutureBuilder<List<Routes>>(
                    future: DBProvider.db.getAllRoutes(1),
                    builder: (BuildContext context, AsyncSnapshot<List<Routes>> snapshot) {
                      if (snapshot.hasData) {
                        print(snapshot.data.length);
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            //print(snapshot.data.length);
                            Routes item = snapshot.data[index];
                            print('item: ${item.latitude} - ${item.longitude} - ${item.time_event}');
                            return new Container(
                              child: ListTile(
                                title: Text(item.latitude.toString() +  " - " + item.longitude.toString()),
                                leading: Text(item.altitude.toString()),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                // -------


/*
                //-----
                Flexible(
                  child: FutureBuilder<List<Routes>>(
                    future: DBProvider.db.getAllRoutes(),
                    builder: (BuildContext context, AsyncSnapshot<List<Routes>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            Routes item = snapshot.data[index];
                            Container(
                              child: ListTile(
                                title: Text(item.latitude.toString() +  " - " + item.longitude.toString()),
                                leading: Text(item.altitude.toString()),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                // -------
*/

              ],
            ),
          );

        })
    );
  }
}
/*
        FutureBuilder<List<Routes>>(
        future: DBProvider.db.getAllRoutes(),
        builder: (BuildContext context, AsyncSnapshot<List<Routes>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Routes item = snapshot.data[index];
                Container(
                  child: ListTile(
                    title: Text(item.latitude.toString() +  " - " + item.longitude.toString()),
                    leading: Text(item.altitude.toString()),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
*/
/*
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          Client rnd = testClients[math.Random().nextInt(testClients.length)];
          await DBProvider.db.newClient(rnd);
          setState(() {});
        },
      ),
*/

