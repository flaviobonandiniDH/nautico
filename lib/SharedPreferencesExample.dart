import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> _languages = <String>['de','us','es','fr','it','nl','pt'];
List<String> _mapserver = <String>['https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                   'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',];

class ShowSelectRadio extends StatefulWidget {
  @override
  ShowSelectRadioState createState() {
    return new ShowSelectRadioState();
  }
}

class ShowSelectRadioState extends State<ShowSelectRadio> {
  int _currVal = 1;
  String _currText = '';

  List<GroupModel> _group = [
    GroupModel(
      text: "pippo",
      index: 1,
    ),
    GroupModel(
      text: "pluto",
      index: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Show Selected Radio  Example"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(_currText,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          Expanded(
              child: Container(
                height: 350.0,
                child: Column(
                  children: _group
                      .map((t) => RadioListTile(
                    title: Text("${t.text}"),
                    groupValue: _currVal,
                    value: t.index,
                    onChanged: (val) {
                      setState(() {
                        _currVal = val.index;
                        _currText = t.text;
                      });
                    },
                  ))
                      .toList(),
                ),
              )),
        ],
      ),
    );
  }
}

class GroupModel {
  String text;
  int index;
  GroupModel({this.text, this.index});
}
/*
class SharedPreferencesHelper {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final String _kLanguageCode = "language";
  static final String _kMapping_server = "server";

  /// ------------------------------------------------------------
  /// Method that returns the user language code, 'us' if not set
  /// ------------------------------------------------------------
  static Future<String> getLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kLanguageCode) ?? 'us';
  }

  /// ----------------------------------------------------------
  /// Method that saves the user language code
  /// ----------------------------------------------------------
  static Future<bool> setLanguageCode(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kLanguageCode, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the mappin provider if not set = 0
  /// ------------------------------------------------------------
  static Future<int> getMapServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_kMapping_server) ?? '0';
  }

  /// ----------------------------------------------------------
  /// Method that saves the the mappin provider
  /// ----------------------------------------------------------
  static Future<bool> setMapServer(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_kMapping_server, value);
  }

}*/
