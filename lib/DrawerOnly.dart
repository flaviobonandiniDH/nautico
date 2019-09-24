import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nautico/CoresSensorNewX.dart';
import 'package:nautico/GeoMap.dart';
import 'package:nautico/GeoLocation.dart';
import 'package:nautico/GoogleMaps.dart';
import 'package:nautico/SharedPreferences.dart';
import 'package:nautico/ShowDataRoute.dart';
import 'package:nautico/localStorageData.dart';
import 'package:nautico/localStorageRoutes.dart';
import 'package:nautico/login/LoginPage.dart';
import 'package:nautico/login/CreateAccount.dart';
import 'ShowDataDevice.dart';
class DrawerOnly extends StatelessWidget {
  @override
  Widget build (BuildContext ctxt) {
    return new Drawer(
        elevation: 20.0,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('CoreSensor Connect and Data Receiver ',
                style: TextStyle(fontSize: 14.0, color: Colors.blue),),
              accountEmail: Text('Routes and Maps Management',
                style: TextStyle(fontSize: 14.0, color: Colors.blue),),
              currentAccountPicture:
              Image(image: AssetImage("images/doghunter.png",),width: 150.0,height: 150.0,fit: BoxFit.cover,),
              decoration: BoxDecoration(color: Colors.white),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app,color: Colors.red,),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new MyLoginPage()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.devices,color: Colors.lightBlue,),
              title: Text('Show Data Device from Server'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new ShowDataDevice()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.settings,color: Colors.red,),
              title: Text('Setting Maps Provider'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new SettingPreferences()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.receipt,color: Colors.deepOrangeAccent),
              title: Text('Show Data Routes from Server'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new ShowDataRoutes()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.map,color: Colors.green),
              title: Text('Show Routes in Open source Map'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new MyGeoPage()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.map,color: Colors.blue[200]),
              title: Text('Show Routes in Open Google Maps'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new GoogleMapsPage('0')));
              },
            ),

            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.location_on,color: Colors.pink),
              title: Text('My Geo Localization'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new MyLocationPage()));
              },
            ),

            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.bluetooth,color: Colors.blue[800]),
              title: Text('Connect to Core Sensor Board'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new CoreSensoApp(title: "Core Sensor BLE",)));
              },
            ),

            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.archive,color: Colors.blue[800]),
              title: Text('Data Management'),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new LocalStorageRoutes()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ///
            ///
          ]
        )

    );
  }
}



/*

class DrawerOnly extends StatelessWidget {
  @override
  Widget build (BuildContext ctxt) {
    return new Drawer(
        child: new ListView(
          children: <Widget>[
            new DrawerHeader(
              child: new Text("DRAWER HEADER.."),
              decoration: new BoxDecoration(
                  color: Colors.orange
              ),
            ),
            new ListTile(
              title: new Text("Item => 1"),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new MyGeoPage()));
              },
            ),
            new ListTile(
              title: new Text("Item => 2"),
              onTap: () {
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new MyLocationPage()));
              },
            ),
          ],
        )
    );
  }
}*/
