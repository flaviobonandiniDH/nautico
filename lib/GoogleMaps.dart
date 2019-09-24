import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nautico/model/jsonModelRoute.dart';
import 'package:nautico/model/jsonModelRouteLookUp.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nautico/DrawerOnly.dart';


class GoogleMapsPage extends StatefulWidget {

String _starterRouteMap;
GoogleMapsPage(String starterRouteMap) {
  this._starterRouteMap = starterRouteMap;
}


  @override
  _GoogleMapsPage createState() => new _GoogleMapsPage(_starterRouteMap);
}

class _GoogleMapsPage extends State<GoogleMapsPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext scaffoldContext;

  GoogleMapController GMcontroller;

  String _starterRouteMap;
  _GoogleMapsPage(String starterRouteMap) {
    this._starterRouteMap = starterRouteMap;
  }

  int numRoute =0;
  Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;

  final double _zoom = 11;

  // Values when toggling polyline color
  int colorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];

  // Values when toggling polyline width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  int jointTypesIndex = 0;
  List<JointType> jointTypes = <JointType>[
    JointType.mitered,
    JointType.bevel,
    JointType.round
  ];

  // Values when toggling polyline end cap type
  int endCapsIndex = 0;
  List<Cap> endCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  // Values when toggling polyline start cap type
  int startCapsIndex = 0;
  List<Cap> startCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  // Values when toggling polyline pattern
  int patternsIndex = 1;
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[],
    <PatternItem>[
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)],
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)],
  ];

  final String URL_ROUTE_COORD = "https://developer.linino.org/iot_sensor-coord.php?action=list_json_coord&id_route=";
  final String URL_ROUTE_LOOKUP = "https://developer.linino.org/iot_sensor-coord.php?action=get_route_lookUp&id_route=";

  LatLng LatLenPoints;
  var routePoints =<LatLng>[];

  LatLng startRoute = LatLng(41.297278, 9.170362);
  LatLng stoptRoute = LatLng(41.297278, 9.170362);

  String timeStartRoute;
  String timeStopRoute;

  String NameRoute;
  String DescriptionRoute;



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

    timeStartRoute = ListJson.models[0].TEV;
    timeStopRoute = ListJson.models[(jsonResponse.length - 1)].TEV;
    print('routePoints ${routePoints.toString()}');
    print('routePoints first  ${routePoints[0].toString()}');
    print('routePoints last  ${routePoints[jsonResponse.length-1].toString()}');

    startRoute = routePoints[0];
    stoptRoute = routePoints[jsonResponse.length-1];
    //SchedulerBinding.instance.addPostFrameCallback((_) => fitBounds());

    this.loadDataHttpLookUp(nRoute);

    //this._goToRoute(startRoute);
    setState(() {
      //
    });
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


/*
  Future fitBounds() async {

    var bounds = new LatLngBounds();

    print("PASSATO fitBounds");
    //var bounds = LatLngBounds();
    bounds.   .extend(startRoute);
    bounds.extend(stoptRoute);
    await fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(20),
        //padding: EdgeInsets.only(left: 1.0, right: 1.0),
        //oom: mapController.zoom - 2
      ),
    );
    mapController.move(mapController.center, (mapController.zoom - 0.3));
  }
*/

  Future selectRoute() async {
    numRoute = (numRoute + 1) < 3 ? (numRoute + 1) : 0;
    await loadDataHttpRoute(numRoute);

    setState(() {

    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.297278, 9.170362),
    zoom: 10.4746,
  );

/*
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
*/

      MapType _map_hibrid = MapType.hybrid;
      MapType _map_normal = MapType.normal;
      MapType _mapType = MapType.normal;
      MapType nextType = MapType.hybrid;



  @override
  void setState(fn) {
    print("PASSED-> setState.");
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    print("starterRouteMap: $_starterRouteMap");

    numRoute = (_starterRouteMap != null) ? int.parse(_starterRouteMap) : 0;
    this.loadDataHttpRoute(numRoute);
    this.loadDataHttpLookUp(numRoute);
    //this.loadRoute();

    //this.getRoutePoints();
  }
  @override
  Widget build(BuildContext context) {

    MarkerId mrkStart =  MarkerId("$numRoute" + " _start");
    MarkerId mrkStop = MarkerId("$numRoute" + " _stop");


    List<Marker> markers = <Marker>[
      Marker(
        markerId: mrkStart,
        position: startRoute,
        infoWindow: InfoWindow(
          title: 'Start: $NameRoute',
          snippet: timeStartRoute,
          onTap:() {
            print(numRoute);
            _createSnackBar(DescriptionRoute,Colors.yellow, Colors.black,5);
          },

        ),

        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: mrkStop,
        position: stoptRoute,
        infoWindow: InfoWindow(
          title: 'End: $NameRoute',
          snippet: timeStopRoute,
          onTap:() {
            print(numRoute);
            _createSnackBar(DescriptionRoute,Colors.yellow, Colors.black,5);
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    ];


    return new Scaffold(


      appBar: new AppBar(
        title: new Text("Google Maps"),
        backgroundColor: Colors.blue,
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
                      new Container(
                      padding: const EdgeInsets.fromLTRB(15.0,5.0,10.0,5.0),
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                        color: Colors.greenAccent[50],
                      ),
                      child:
                        Text(
                          'Route: $NameRoute',
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          textAlign: TextAlign.center
                        ),
                      ),
                  ],
                ),

              ),

              Flexible(
                child: GoogleMap(
                  //padding: EdgeInsets.all(30),
                  mapType: _mapType,
                  myLocationEnabled: true,
                  onLongPress: ((xxx) {
                    debugPrint("xxx.longitude: ${xxx.longitude}");
                    debugPrint("xxx.latitude: ${xxx.latitude}");
                  }),
                  initialCameraPosition: _kGooglePlex,
                  markers: Set<Marker>.of(markers),
                  polylines: Set<Polyline>.of(polylines.values),
                  onMapCreated: (GoogleMapController controller) {
                    _add(); //Add routes
                    controller.animateCamera(CameraUpdate.newLatLngZoom(startRoute, _zoom));
                  },
                ),
              ),
              /*
                    MaterialButton(
                      child: Text('$_starterRouteMap'),
                      onPressed: _add,
                    ),
                    MaterialButton(
                      child: Text('remove'),
                      onPressed:
                      (selectedPolyline == null) ? null : _remove,
                    ),

                    MaterialButton(
                      child: Text('tg. vis.'),
                      onPressed: (selectedPolyline == null)
                          ? null
                          : _toggleVisible,
                    ),
                    MaterialButton(
                      child: Text('Route ${ (numRoute + 1) < 3 ?  (numRoute + 1).toString() : 0}'),
                      onPressed: () {
                        selectRoute();
                        _createSnackBar("Data Server Reloding ",Colors.red, Colors.white,2);
                        //mapController.move(mapController.center, (mapController.zoom + 2));
                      },

                   ),
*/


            ],
          ),
        );
      }),

/*
        body: GoogleMap(
          mapType: _mapType,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
*/

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton(
        child: new Icon(Icons.map),
        onPressed: () {

          nextType = MapType.values[(_mapType.index + 1) % MapType.values.length];
          //debugPrint("nextType: $nextType");
          nextType = (nextType != MapType.none) ? nextType : MapType.normal;
          setState(() {
            //nextType = MapType.values[(_mapType.index + 1) % MapType.values.length];
            _mapType = nextType;
            //print("_mapType: $_mapType");
          });
        },
      ),
/*
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
*/
    );
  }

  Future<void> _goToRoute(LatLng position) async {
//    double lat = 40.7128;
//    double long = -74.0060;
  debugPrint("ECCOLO: $position");
    GoogleMapController controller;
    controller.animateCamera(CameraUpdate.newLatLngZoom(startRoute, 15));

  }

  void _onPolylineTapped(PolylineId polylineId) {
    setState(() {
      selectedPolyline = polylineId;
    });
  }

  void _remove() {
    setState(() {
      if (polylines.containsKey(selectedPolyline)) {
        polylines.remove(selectedPolyline);
      }
      selectedPolyline = null;
    });
  }

  void _add() {
    final int polylineCount = polylines.length;

    if (polylineCount == 12) {
      return;
    }

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    debugPrint("polylineId: $polylineId");
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: colors[numRoute],
      width: 5,
      points: routePoints,
      onTap: () {
        _onPolylineTapped(polylineId);
      },
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  void _toggleGeodesic() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        geodesicParam: !polyline.geodesic,
      );
    });
  }

  void _toggleVisible() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        visibleParam: !polyline.visible,
      );
    });
  }



  void _changeColor() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        colorParam: colors[++colorsIndex % colors.length],
      );
    });
  }

  void _changeWidth() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        widthParam: widths[++widthsIndex % widths.length],
      );
    });
  }

  void _changeJointType() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        jointTypeParam: jointTypes[++jointTypesIndex % jointTypes.length],
      );
    });
  }

  void _changeEndCap() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        endCapParam: endCaps[++endCapsIndex % endCaps.length],
      );
    });
  }

  void _changeStartCap() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        startCapParam: startCaps[++startCapsIndex % startCaps.length],
      );
    });
  }

  void _changePattern() {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        patternsParam: patterns[++patternsIndex % patterns.length],
      );
    });
  }

  void _createSnackBar(String message, Color BGcolore, Color FGcolore, int duration) {
    final snackBar = new SnackBar(content:
        new Text(message,
              style: TextStyle(
                color: FGcolore,
                decorationStyle: TextDecorationStyle.wavy,
              ),
        ),
        duration: Duration(seconds: duration),
        backgroundColor: BGcolore,
    );
    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }


/*

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }


  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    final double offset = _polylineIdCounter.ceilToDouble();
    points.add(_createLatLng(51.4816 + offset, -3.1791));
    points.add(_createLatLng(53.0430 + offset, -2.9925));
    points.add(_createLatLng(53.1396 + offset, -4.2739));
    points.add(_createLatLng(52.4153 + offset, -4.0829));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

*/

}