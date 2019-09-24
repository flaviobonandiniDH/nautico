import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nautico/DrawerOnly.dart';

class SettingPreferences extends StatefulWidget {
  @override
  _SettingPreferencesState createState() => new _SettingPreferencesState();
  }

  class _SettingPreferencesState extends State<SettingPreferences> {
    static final String _kMapping_server = "server";
    static final String _kFlag_overlay = "overlay";

    int setMap;
    String setMapStr;
    String _picked = "0";
    bool checkSemark = false;

    @override
    void setState(fn) {
      if(mounted){
        super.setState(fn);
      }
    }

    @override
    void initState() {
      super.initState();
      this.getMapServer();
      this.getFlagOverlay();
    }


    Future<int> getMapServer() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //bool testInt = await prefs.setInt(_kMapping_server, 1);
      setMap = await prefs.getInt(_kMapping_server);
      print("_picked: $_picked");
      setState(() {
        _picked = setMap.toString();
      });

      print("PASSATO");
      print("setMap: $setMap");
      print("_picked: $_picked");

    }

    Future<int> setMapServer(int value) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //bool testInt = await prefs.setInt(_kMapping_server, 1);
      bool testFunc = await prefs.setInt(_kMapping_server,value);
      print("testFunc: $testFunc");
      setState(() {
        setMap = value;
        //_picked = setMap.toString();
      });
      print("PASSATO 2");

    }

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

    Future<bool> setFlagOverlay() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //bool testInt = await prefs.setInt(_kMapping_server, 1);
      bool testFunc = await prefs.setBool(_kFlag_overlay,!checkSemark);
      print("testFunc: $testFunc");
      setState(() {
        checkSemark = !checkSemark;
        //_picked = setMap.toString();
      });
      print("PASSATO 2");

    }

    List<String> _providerHttplink = <String>[
      'null for 0 index',
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
      'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png'
    ];


    List<String> _provider = ["1", "2", "3"];
    List<String> _providerString = [" : OSM - Open Street Map", " : ArcGIS - esri", " : Wikimedia Maps"];
    List<String> _providerImage = ["images/osm.jpeg", "images/esri.png", "images/osm.jpeg"];
    List<Color> _providerColors = [Colors.lightGreenAccent,Colors.amberAccent,Colors.cyanAccent];
    List<Color> _providerStringColors = [Colors.deepPurple,Colors.deepPurple,Colors.deepPurple];

    void _value1Changed(bool value) {
      setFlagOverlay();
    }

    @override
    Widget build(BuildContext context){
      return Scaffold(

        appBar: new AppBar(
          title: new Text("Setting Maps Provider"),
          backgroundColor: Colors.red,
        ),
        drawer:  DrawerOnly(),

        body: _body(),
      );
      //
    }

    Widget _body(){
      return ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 14.0, top: 14.0, bottom: 3.0),
              child: Text("Choose Map Provider",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                ),
              ),
            ),

            RadioButtonGroup(
              onSelected: (String selected) => setState((){
                _picked = selected;
              }),
              labels: _provider,
              labelStyle: new TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
              picked: _picked,
              itemBuilder: (Radio rb, Text txt, int i){
                return Column(
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.fromLTRB(15, 5, 2, 1) ,
                      decoration: new BoxDecoration(
                        borderRadius:BorderRadius.all(Radius.circular(2.0)),
                        color: _providerColors[i],
                      ),
                      child:
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                _providerImage[i],
                                width: 40.0,
                                height: 40.0,
                                fit: BoxFit.cover,
                              ),rb,txt,
                              Text(_providerString[i],
                                  style: new TextStyle(
                                    color: _providerStringColors[i],
                                    fontSize: 16.0,
                                  )),
                            ],
                        ),
                    ),
                  ],
                );
              },
              onChange: (String label, int index) => {
                    print("label: $label index: $index"),
                    setMapServer(index+1)
              },
              //onSelected: (String label) => print(label),
            ),

            Divider(),

/*
            Column(
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.fromLTRB(15, 5, 2, 1) ,
                  decoration: new BoxDecoration(
                    borderRadius:BorderRadius.all(Radius.circular(2.0)),
                    color: _providerColors[1],
                  ),
                  child:
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[

                      //new Checkbox(value: checkSemark, onChanged: _value1Changed),
                      new Checkbox(value: checkSemark, onChanged: (bool  val) => {setFlagOverlay()}),

                      Text("Use OpenSeaMap Markers Overlay",
                          style: new TextStyle(
                            color: _providerStringColors[1],
                            fontSize: 16.0,
                          )),
                    ],
                  ),
                ),
              ],
            ),
*/

/*

                child: new Column(
                    children: <Widget>[
                      new Checkbox(value: checkSemark, onChanged: _value1Changed),
                    ]
                ),
*/

          ]
      );
  }
}