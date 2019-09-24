import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nautico/model/jsonModelRoute.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:nautico/DrawerOnly.dart';

class MyGeoPage extends StatefulWidget {
  @override
  _MyGeoPageState createState() => new _MyGeoPageState();
}

class _MyGeoPageState extends State<MyGeoPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext scaffoldContext;

  LatLng startRoute = LatLng(41.297278, 9.170362);
  LatLng stoptRoute = LatLng(41.297278, 9.170362);

  int numRoute = 0;

  MapController mapController;
  var _route_1;
  //FlutterMap _map;
  bool routeCarried = false;

  static final String _kMapping_server = "server";
  //static final String _kFlag_overlay = "overlay";
  int setMap;
  //bool checkSemark = false;

  List<String> _providerHttplink = <String>[
    'null for 0 index',
    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
    'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png'
  ];

  List<String> _providerTitle = [
    'null for 0 index',
    'OSM - Open Street Map',
    'ArcGIS - esri',
    'Wikimedia Maps'
  ];

  // http://tiles.openseamap.org/seamark/${z}/${x}/${y}.png

  String urlMap;
  String urlMapTitle;

  final String URL_ROUTE_COORD = "https://developer.linino.org/iot_sensor-coord.php?action=list_json_coord&id_route=";
  final String URL_ROUTE_LOOKUP = "https://developer.linino.org/iot_sensor-coord.php?action=get_route_lookUp&id_route=";


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
    return setMap;
  }
/*

  Future<bool> getFlagOverlay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //bool testInt = await prefs.setInt(_kMapping_server, 1);
    bool value = await prefs.getBool(_kFlag_overlay);
    if (value == null) (value = false);
    setState(() {
      checkSemark = value;
    });

    print("PASSATO");
    print("checkSemark: $checkSemark");


  }
*/



  @override
  void initState() {
    super.initState();
    this.loadDataHttpRoute(numRoute);
    this.getMapServer();
    //this.getFlagOverlay();
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

  Future loadDataHttpRoute(int nRoute) async {
    String urlRouteNumber = URL_ROUTE_COORD + nRoute.toString();
    http.Response response = await http.get(
        Uri.encodeFull(urlRouteNumber),
        headers: {"Accept": "application/json"});
    //print('HTTP-loadDataHttpRoute ${response.body}');
    String jsonString = response.body;
    final jsonResponse = json.decode(jsonString);
    JsonListRoute ListJson = new JsonListRoute.fromJson(jsonResponse);
    print('HTTP-loadDataHttpRoute ${jsonResponse}');

    routePoints.clear();

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
        padding: EdgeInsets.all(20),
        //padding: EdgeInsets.only(left: 1.0, right: 1.0),
        //oom: mapController.zoom - 2
      ),
    );
    mapController.move(mapController.center, (mapController.zoom - 0.3));
  }


  Future selectRoute() async {
    numRoute = (numRoute + 1) < 3 ? (numRoute + 1) : 0;
    await loadDataHttpRoute(numRoute);
    loadRoute();
    setState(() {

    });
  }

  loadRoute() {
    print("loadRoute");
    //Color colorRoute = Colors.redAccent;
    //Color colorRoute = Color(4285132974);  //green accent
    Color colorRoute = Color(4294922834);  //red accent
    print('color = ${colorRoute.value}');
    _route_1 = <Polyline>[
      Polyline(
        points: routePoints,
        strokeWidth: 3.0,
        color: colorRoute,
        isDotted: true,
      ),
    ];
    //routeCarried = true;
  }

  void _onSearchButtonPressed() {
    print("search button clicked");
  }
  @override
  Widget build(BuildContext context) {

    var markers = <Marker>[
       Marker(
          anchorPos: AnchorPos.align(AnchorAlign.top),
          width: 45.0,
          height: 45.0,
          point: startRoute,
          builder: (context) => new Container(
            child: IconButton(
              icon: Icon(Icons.location_on),
              color: Colors.green,
              iconSize: 45.0,
              onPressed: () { },
            ),
          )
      ),


      Marker(
        anchorPos: AnchorPos.align(AnchorAlign.top),
        width: 45.0,
        height: 45.0,
        point: stoptRoute,
        builder: (context) => Icon(Icons.pin_drop, color: Colors.red, size: 45.0),
      ),

/*
      Marker(
          anchorPos: AnchorPos.align(AnchorAlign.top),
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
          anchorPos: AnchorPos.align(AnchorAlign.top),
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
*/
    ];
/*

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => fitBounds());
    }

*/
    return Scaffold(
      key: _scaffoldKey,

      appBar: new AppBar(
        title: new Text(urlMapTitle),
        backgroundColor: Colors.green,
      ),
      drawer:  DrawerOnly(),

      body: new Builder(builder: (BuildContext context) {
        scaffoldContext = context;
        return new Padding(
        padding: EdgeInsets.only(left: 2.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.5, bottom: 0.5),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    child: Text('Start R.'),
                    onPressed: () {
                      mapController.move(startRoute, 15.0);
                    },
                  ),
                  MaterialButton(
                    child: Text('End R.'),
                    onPressed: () {
                      mapController.move(stoptRoute, 15.0);
                    },
                  ),

                  MaterialButton(
                    child: Text('Fit'),
                    onPressed: () {
                      fitBounds();
                    },
                  ),
                  MaterialButton(
                    child: Text('Route ${ (numRoute + 1) < 3 ?  (numRoute + 1).toString() : 0}'),
                    onPressed: () {
                      selectRoute();
                      _createSnackBar("Data Server Reloding ","GREEN");
                      //mapController.move(mapController.center, (mapController.zoom + 2));
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
                      //'http://tiles.openseamap.org/{z}/{x}/{y}.png',
                      //'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),


                  new TileLayerOptions(
                      backgroundColor: new Color.fromRGBO(0, 0, 0, 0),
                      urlTemplate:
                      //urlMap,
                      //'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      'http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                      //'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
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


/*
            Padding(
              padding: EdgeInsets.only(top: 0.5, bottom: 0.5),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    child: Text('Start'),
                    onPressed: () {
                      mapController.move(startRoute, 15.0);
                    },
                  ),
                  MaterialButton(
                    child: Text('End'),
                    onPressed: () {
                      mapController.move(stoptRoute, 15.0);
                    },
                  ),

                  MaterialButton(
                    child: Text('Fit'),
                    onPressed: () {
                      fitBounds();
                    },
                  ),
                  MaterialButton(
                    child: Text('Route ${ (numRoute + 1) < 3 ?  (numRoute + 1).toString() : 0}'),
                    onPressed: () {
                      selectRoute();
                      //mapController.move(mapController.center, (mapController.zoom + 2));
                    },
                  ),
                ],
              ),
            ),
*/


          ],
        ),
      );
    }),
  );
}

  void _createSnackBar(String message, String colore) {
    final snackBar = new SnackBar(content: new Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: (colore == "RED") ? Colors.red : Colors.green);

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
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

  _buildActionButtons() {
      return <Widget>[
        new IconButton(icon: const Icon(Icons.home), onPressed: () {
          Navigator.pop(context);
          //Navigator.push(context,MaterialPageRoute(builder: (context) => ChartShow(title: _mySelection_name,)),);
          //_createSnackBar("Button Disabled ","RED");
        }),
      ];
  }
}