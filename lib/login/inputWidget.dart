import 'package:flutter/material.dart';

final mailController = TextEditingController();
final pwdController = TextEditingController();

class InputWidget extends StatelessWidget {
  final double topRight;
  final double bottomRight;
  final int typeOfText;  //0 = mail -:- 1 = pwd

  InputWidget(this.topRight, this.bottomRight, this.typeOfText);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 40, bottom: 30),
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        child: Material(
          elevation: 10,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(bottomRight),
                  topRight: Radius.circular(topRight))),
          child: Padding(
            padding: EdgeInsets.only(left: 40, right: 20, top: 10, bottom: 10),
            child:
            typeOfText == 0 ?     //test controller (TextEditingController) 0 = Mail -:- 1 = Pwd
                TextField(
                  controller: mailController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "JohnDoe@example.com",
                      hintStyle: TextStyle(color: Color(0xFFE1E1E1), fontSize: 14)),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                )
            :       //passo dal controller Mail al controller Pwd (TextEditingController)
                TextField(
                  controller: pwdController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "doghunter",
                      hintStyle: TextStyle(color: Color(0xFFE1E1E1), fontSize: 14)),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                )
          ),
        ),
      ),
    );
  }
}
