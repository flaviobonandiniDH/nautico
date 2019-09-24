import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautico/login/background.dart';
import 'package:nautico/login/loginUi.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyLoginPage(title: 'IOT Doghunter App'),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {


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
