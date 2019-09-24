import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nautico/model/jsonModelRoute.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';

class MyGeoPage extends StatefulWidget {
  @override
  _MyGeoPageState createState() => new _MyGeoPageState();
}

class _MyGeoPageState extends State<MyGeoPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LatLng startRoute = LatLng(41.297278, 9.170362);
  LatLng stoptRoute = LatLng(41.297278, 9.170362);

  MapController mapController;
  var _route_1;
  FlutterMap _map;
  bool routeCarried = false;

  static final String _kMapping_server = "server";
  int setMap;
  List<String> _providerHttplink = <String>['null for 0 index','https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',];
  List<String> _providerTitle = ['null for 0 index', 'OSM - Open Street Map', 'ArcGIS - esri'];

  String urlMap;
  String urlMapTitle;

  Future<int> getMapServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //bool testInt = await prefs.setInt(_kMapping_server, 1);
    try {
      setMap = await prefs.getInt(_kMapping_server);
      print("PASSATO");
      print("setMap: $setMap");
    } catch(exception) {
      print('${exception.toString()}');
      setMap = 1;
    }


    setState(() {
      urlMap = _providerHttplink[setMap];
      urlMapTitle = _providerTitle[setMap];
    });

  }

  final String url = "https://developer.linino.org/iot_sensor-coord.php?action=list_json_coord";

  @override
  void initState() {
    super.initState();
    this.loadDataHttpRoute();
    this.getMapServer();
    this.loadRoute();
    mapController = MapController();

    //this.getRoutePoints();
  }

  @override
  void setState(fn) {
    print("PASSED-> setState.");
    if(mounted){
      super.setState(fn);
    }
  }

  LatLng LatLenPoints;
  var routePoints =<LatLng>[];

  Future loadDataHttpRoute() async {

    http.Response response = await http.get(
        Uri.encodeFull(url),
        headers: {"Accept": "application/json"});
    //print('HTTP-loadDataHttpRoute ${response.body}');
    String jsonString = response.body;
    final jsonResponse = json.decode(jsonString);
    JsonListRoute ListJson = new JsonListRoute.fromJson(jsonResponse);
    print('HTTP-loadDataHttpRoute ${jsonResponse}');


    for (int i = 0; i < jsonResponse.length; i++) {
      //print("ListJson -> ");
      //print("matRoutePoints ${ListJson.models[i].LAT.toString()} - ${ListJson.models[i].LNG.toString()}");
      //LatLenPoints.latitude = double.parse(ListJson.models[i].LAT.toString());
      //LatLenPoints.longitude = double.parse(ListJson.models[i].LNG.toString());
      routePoints.add(LatLng(double.parse(ListJson.models[i].LAT),double.parse(ListJson.models[i].LNG)));
      //matRoutePoints.add(double.parse(jsonResponse[i]['Key_02']));
    }

    print('routePoints ${routePoints.toString()}');
    print('routePoints first  ${routePoints[0].toString()}');
    print('routePoints last  ${routePoints[jsonResponse.length-1].toString()}');

    startRoute = routePoints[0];
    stoptRoute = routePoints[jsonResponse.length-1];
    SchedulerBinding.instance.addPostFrameCallback((_) => fitBounds());

    setState(() {
      //
    });
  }

  /*
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
                  ) : new Container(),
                ),

   */
  Future fitBounds() async {
    print("PASSATO fitBounds");
    var bounds = LatLngBounds();
    bounds.extend(startRoute);
    bounds.extend(stoptRoute);
    await mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(10),
        //padding: EdgeInsets.only(left: 1.0, right: 1.0),
        //oom: mapController.zoom - 2
      ),
    );

  }

  loadRoute() {
    print("loadRoute");
    _route_1 = <Polyline>[
      Polyline(
        points: routePoints,
        strokeWidth: 3.0,
        color: Colors.redAccent,
        isDotted: true,
      ),
    ];
    //routeCarried = true;

  }
  @override
  Widget build(BuildContext context) {

    var markers = <Marker>[
      Marker(
          width: 45.0,
          height: 45.0,
          point: startRoute,
          builder: (context) => new Container(
            child: IconButton(
              icon: Icon(Icons.location_on),
              color: Colors.green,
              iconSize: 45.0,
              onPressed: () {
                print('Marker tapped');
              },
            ),
          )
      ),

      Marker(
          width: 45.0,
          height: 45.0,
          point: stoptRoute,
          builder: (context) => new Container(
            child: IconButton(
              icon: Icon(Icons.location_on),
              color: Colors.red,
              iconSize: 45.0,
              onPressed: () {
                print('Marker tapped');
              },
            ),
          )
      ),

    ];
/*

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => fitBounds());
    }

*/
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(urlMapTitle),
          leading: IconButton(icon:Icon(Icons.arrow_back),
            onPressed:() => Navigator.of(context).pop(),
          )
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 2.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.5, bottom: 0.5),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    child: Text('Start Route'),
                    onPressed: () {
                      mapController.move(startRoute, 15.0);
                    },
                  ),
                  MaterialButton(
                    child: Text('Stop Route'),
                    onPressed: () {
                      mapController.move(stoptRoute, 15.0);
                    },
                  ),
                  MaterialButton(
                    child: Text('Fit Bounds'),
                    onPressed: () {
                      fitBounds();
                    },
                  ),
                ],
              ),

            ),
/*
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    child: Text('Fit Bounds'),
                    onPressed: () {
                      var bounds = LatLngBounds();
                      bounds.extend(startRoute);
                      bounds.extend(stoptRoute);

                      mapController.fitBounds(
                        bounds,
                        options: FitBoundsOptions(
                          padding: EdgeInsets.all(10),
                          //padding: EdgeInsets.only(left: 1.0, right: 1.0),
                        ),
                      );
                    },
                  ),
                  MaterialButton(
                    child: Text('Get Bounds'),
                    onPressed: () {
                      final bounds = mapController.bounds;

                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          'Map bounds: \n'
                              'E: ${bounds.east} \n'
                              'N: ${bounds.north} \n'
                              'W: ${bounds.west} \n'
                              'S: ${bounds.south}',
                        ),
                      ));
                    },
                  ),
                ],
              ),
            ),
*/
            Flexible(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: LatLng(41.297278, 9.170362),
                  zoom: 12.0,
                  maxZoom: 18.0,
                  minZoom: 3.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                      urlMap,
                      //'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: markers),

                  new PolylineLayerOptions(
                    polylines: _route_1,

                    //polylines: routeCarried == true ? _route_1 : null
/*

                    [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 3.0,
                        color: Colors.redAccent,
                        isDotted: true,
                      ),

                    ],
*/
                  ),

              ],
              ),
            ),
          ],
        ),
      ),
    );
}

/*
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(urlMapTitle),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.of(context).pop(),
            )
        ),




        body: new FlutterMap(

          options: new MapOptions(
              center: new LatLng(41.297278, 9.170362),
              minZoom: 2.0,
              maxZoom: 18.0,
              zoom: 12.0
          ),
          layers: [
            new TileLayerOptions(
              urlTemplate:
              urlMap,
              //'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
              //"https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']
            ),
            new PolylineLayerOptions(
                polylines: [
                  Polyline(
                      points: routePoints,
                      strokeWidth: 3.0,
                      color: Colors.redAccent,
                      isDotted: true,
                      ),
                ],
            ),
            new MarkerLayerOptions(
              markers: [
                new Marker(
                  width: 45.0,
                  height: 45.0,
                  point: new LatLng(41.297278, 9.170362),
                  builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: Colors.red,
                      iconSize: 45.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  )
                )
              ]
            )
          ]
        )
    );
  }
*/
/*

  _buildActionButtons() {
      return <Widget>[
        new IconButton(icon: const Icon(Icons.home), onPressed: () {
          Navigator.pop(context);
          //Navigator.push(context,MaterialPageRoute(builder: (context) => ChartShow(title: _mySelection_name,)),);
          //_createSnackBar("Button Disabled ","RED");
        }),
      ];
  }*/
}