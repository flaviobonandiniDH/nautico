import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautico/login/background.dart';
import 'package:nautico/login/loginUi.dart';


class CreateAccount extends StatefulWidget {
  CreateAccount({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {


  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    //dateNow();

  }

  BuildContext scaffoldContext;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Background(),
            Login(),
          ],
        ));
  }
}
