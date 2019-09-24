import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nautico/model/jsonModelLogin.dart';
/*

class Post {
  final String status;
  final String id;
  final String message;
  final String mail;
  final int active;
  final String password;

  Post({this.status, this.id, this.message, this.mail, this.active, this.password});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      status: json['status'],
      id: json['iduser'],
      message: json['message'],
      mail: json['mail'],
      active: json['active'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["mail"] = mail;
    map["password"] = password;

    return map;
  }
}*/

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

class MyApp extends StatelessWidget {
  final Future<Post> post;

  MyApp({Key key, this.post}) : super(key: key);
  static final CREATE_POST_URL = 'https://developer.linino.org/simplelogin.php';
  TextEditingController titleControler = new TextEditingController();
  TextEditingController bodyControler = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "WEB SERVICE",
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Create Post'),
          ),
          body: new Container(
            margin: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: new Column(
              children: <Widget>[
                new TextField(
                  controller: titleControler,
                  decoration: InputDecoration(
                      hintText: "mail", labelText: 'Mail'),
                ),
                new TextField(
                  controller: bodyControler,
                  decoration: InputDecoration(
                      hintText: "password", labelText: 'Password'),
                ),
                new RaisedButton(
                  onPressed: () async {
                    Post newPost = new Post(
                         mail: titleControler.text, password: bodyControler.text);
                    Post p = await createPost(CREATE_POST_URL,
                        body: newPost.toMap());
                    print(p.status);
                    print(p.message);
                  },
                  child: const Text("Create"),
                )
              ],
            ),
          )),
    );
  }
}

void main() => runApp(MyApp());
/*

class Post {
  final String userId;
  final int id;
  final String title;
  final String body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["title"] = title;
    map["body"] = body;

    return map;
  }
}

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

class MyApp extends StatelessWidget {
  final Future<Post> post;

  MyApp({Key key, this.post}) : super(key: key);
  static final CREATE_POST_URL = 'https://jsonplaceholder.typicode.com/posts';
  TextEditingController titleControler = new TextEditingController();
  TextEditingController bodyControler = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "WEB SERVICE",
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Create Post'),
          ),
          body: new Container(
            margin: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: new Column(
              children: <Widget>[
                new TextField(
                  controller: titleControler,
                  decoration: InputDecoration(
                      hintText: "title....", labelText: 'Post Title'),
                ),
                new TextField(
                  controller: bodyControler,
                  decoration: InputDecoration(
                      hintText: "body....", labelText: 'Post Body'),
                ),
                new RaisedButton(
                  onPressed: () async {
                    Post newPost = new Post(
                        userId: "123", id: 0, title: titleControler.text, body: bodyControler.text);
                    Post p = await createPost(CREATE_POST_URL,
                        body: newPost.toMap());
                    print(p.title);
                    print(p.body);
                  },
                  child: const Text("Create"),
                )
              ],
            ),
          )),
    );
  }
}

void main() => runApp(MyApp());*/
