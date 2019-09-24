import 'package:flutter/material.dart';

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
      text: "Flutter.dev",
      index: 1,
    ),
    GroupModel(
      text: "Inducesmile.com",
      index: 2,
    ),
    GroupModel(
      text: "Google.com",
      index: 3,
    ),
    GroupModel(
      text: "Yahoo.com",
      index: 4,
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