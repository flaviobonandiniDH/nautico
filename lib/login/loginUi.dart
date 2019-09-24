import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:nautico/login/inputWidget.dart';
import 'package:nautico/model/jsonModelLogin.dart';
import '../SplashPage.dart';


Future<Post> createPost(String url, {Map body}) async {
  return http.post(url, body: body).then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    print("POST : ${response.body}");
    return Post.fromJson(json.decode(response.body));

  });
}

final CREATE_POST_URL = 'https://developer.linino.org/simplelogin.php';
String user = null;
String titleField = "Email";


class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);
  var title;
  @override
  _LoginState createState() => _LoginState();
}



//class DataTableWidget extends StatelessWidget {
class _LoginState extends State<Login> {

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext scaffoldContext;


  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    return Column(
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.3),
        ),
        Column(
          children: <Widget>[
            ///holds email header and inputField
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 40, bottom: 10),
                  child: Text(
                    "$titleField",
                    style: TextStyle(fontSize: 16, color: Color(0xFF999A9A)),
                  ),
                ),

                user == null ?
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      InputWidget(30.0, 0.0,0),
                      Padding(
                          padding: EdgeInsets.only(right: 50),
                          child: Row(
                            children: <Widget>[

                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 40),
                                     child: Text(
                                      'Enter your email id to continue...',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Color(0xFFA0A0A0),
                                      fontSize: 12),
                                    ),
                                  )
                              ),

                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(),
                                  gradient: LinearGradient(
                                      colors: signMailGradients,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                ),

  /*
                                child: ConstrainedBox(
                                  constraints: BoxConstraints.expand(),
                                    child: FlatButton(
                                      onPressed: () {print("PRESSED");},
                                      padding: EdgeInsets.all(0.0),
                                        child: Image.asset('assets/ic_forward.png')
                                    )
                                ),
  */



                                child: FlatButton(
    /*
                                    onPressed: () async {
                                      Post newPost = new Post(
                                          mail: mailController.text, password: 'doghunter');
                                      Post p = await createPost(CREATE_POST_URL,
                                          body: newPost.toMap());
                                      print(p.status);
                                      print(p.message);
                                      if (p.status == 'true') {
                                        _createSnackBar(p.message,"GREEN");
                                        await new Future.delayed(const Duration(seconds: 2));
                                        Navigator.push(context,MaterialPageRoute(builder: (context) => SplashPage()));
                                      } else {
                                        _createSnackBar(p.message,"RED");
                                      }

                                    },
  */

                                     onPressed: () {
                                       setState(() {
                                         user = mailController.text;
                                         titleField = "Password";
                                       });
                                      print('mailController: ${mailController.text}');
                                      //Navigator.push(context,MaterialPageRoute(builder: (context) => SplashPage()));
                                    },


                                    padding: EdgeInsets.all(0.0),
                                    child: Image.asset('images/ic_forward.png', width: MediaQuery.of(context).size.width/8)

                                ),
                              ),
                            ],
                          ))
                    ],
                  )
                :

                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    InputWidget(30.0, 0.0,1),
                    Padding(
                        padding: EdgeInsets.only(right: 50),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Text(
                                    'Click Blue Arrow ...',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(color: Color(0xFFA0A0A0),
                                        fontSize: 12),
                                  ),
                                )
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                gradient: LinearGradient(
                                    colors: signInGradients,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                              ),

/*
                              child: ConstrainedBox(
                                constraints: BoxConstraints.expand(),
                                  child: FlatButton(
                                    onPressed: () {print("PRESSED");},
                                    padding: EdgeInsets.all(0.0),
                                      child: Image.asset('assets/ic_forward.png')
                                  )
                              ),
*/


                              child: FlatButton(
                                  onPressed: () async {
                                    print('mailController: ${mailController.text}');
                                    print('pwdController: ${pwdController.text}');
                                    Post newPost = new Post(
                                        mail: mailController.text, password: pwdController.text);
                                    Post p = await createPost(CREATE_POST_URL,
                                        body: newPost.toMap());
                                    print(p.status);
                                    print(p.message);
                                    if (p.status == 'true') {
                                      user = null;
                                      titleField = "Email";
                                      _createSnackBar(p.message,"GREEN");
                                      await new Future.delayed(const Duration(seconds: 2));
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => SplashPage()));
                                    } else {
                                      _createSnackBar(p.message,"RED");
                                      setState(() {
                                        user = null;
                                        titleField = "Email";
                                      });
                                    }

                                  },
/*

                                  onPressed: () {
                                    print('mailController: ${mailController.text}');
                                    //Navigator.push(context,MaterialPageRoute(builder: (context) => SplashPage()));
                                  },
*/
                                  padding: EdgeInsets.all(0.0),
                                  child: Image.asset('images/ic_forward.png', width: MediaQuery.of(context).size.width/8)
                              ),

                            ),
                          ],
                        ))
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 50),
            ),
            //roundedRectButton("Let's get Started", signInGradients, false),
            roundedRectButton("Create an Account", signUpGradients, false),
          ],
        )
      ],
    );
  }

  void _createSnackBar(String message, String colore) {
    final snackBar = new SnackBar(content: new Text(message),
        duration: Duration(seconds: 4),
        backgroundColor: (colore == "RED") ? Colors.red : Colors.green);

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }

}

Widget roundedRectButton(
    String title, List<Color> gradient, bool isEndIconVisible) {
  return Builder(builder: (BuildContext mContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment(1.0, 0.0),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(mContext).size.width / 1.7,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: InkWell(
              child: Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                      )
                ),
                onTap: () {
                print('mailController: ${mailController.text}');
                    Navigator.push(mContext,
                    MaterialPageRoute(builder: (context) => SplashPage()),
                    );
                }
            ),padding: EdgeInsets.only(top: 16, bottom: 16),


/*
            Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            padding: EdgeInsets.only(top: 16, bottom: 16),
          ),

          child: Visibility(
            visible: isEndIconVisible,
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ImageIcon(
                  AssetImage("images/ic_forward.png"),
                  size: 30,
                  color: Colors.white,
                )),
*/
          ),
        ],
      ),
    );
  });

}

const List<Color> signInGradients = [
  Color(0xFF0EDED2),
  Color(0xFF03A0FE),
];


const List<Color> signMailGradients = [
  Color(0xFF9CCC65),
  Color(0xFF33691E),
];


const List<Color> signUpGradients = [
  Color(0xFFFF9945),
  Color(0xFFFc6076),
];
