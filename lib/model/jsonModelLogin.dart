

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
}