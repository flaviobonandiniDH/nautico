import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nautico/model/jsonModelRoute.dart';
import 'package:nautico/model/RoutesModelDB.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    print("PASSATO database");

    if (_database != null) return _database;

    // if _database is null we instantiate it
    print("PASSATO if _database is null we instantiate it");
    _database = await initDB();
    return _database;
  }

/*
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Client ("
              "id INTEGER PRIMARY KEY,"
              "first_name TEXT,"
              "last_name TEXT,"
              "blocked BIT"
              ")");
        });

  }
*/

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "iot_client_ble_new.db");
    print("path: $path");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          //print("ONCREATE");
          await db.execute(
              "CREATE TABLE Iot_Routes_Tracker ("
              "id_tracker INTEGER PRIMARY KEY,"
              "id_route INTEGER NOT NULL,"
              "latitude REAL,"
              "longitude REAL,"
              "altitude REAL,"
              "time_event TEXT"
              ");"
              "CREATE TABLE Iot_Routes_LookUp ("
              "id_lookup INTEGER PRIMARY KEY,"
              "id_route INTEGER NOT NULL,"
              "latitude REAL,"
              "longitude REAL,"
              "altitude REAL,"
              "time_event TEXT"
              ");"
          );
        });
  }

/*
  newClient(Client newClient) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Client");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Client (id,first_name,last_name,blocked)"
            " VALUES (?,?,?,?)",
        [id, newClient.firstName, newClient.lastName, newClient.blocked]);
    return raw;
  }
*/
  newRouteRowJson(JsonListRoute newRoute) async {
    final db = await database;
    //get the biggest id in the table

    for (int i = 0; i < newRoute.models.length; i++) {
      var table = await db.rawQuery("SELECT MAX(id_tracker) AS id FROM Iot_Routes_Tracker");
      int id = (table.first["id"] != null) ?  table.first["id"] + 1 : 1;

      var raw = await db.rawInsert(
          "INSERT Into Iot_Routes_Tracker (id_tracker,id_route,latitude,longitude,altitude,time_event)"
              " VALUES (?,?,?,?,?,?)",
          [id, newRoute.models[i].IDR, newRoute.models[i].LAT, newRoute.models[i].LNG, 0, newRoute.models[i].TEV]);

      print('RAW: ${raw.toString()}');
      print("ListJson.models[i] : $id - ${newRoute.models[i].IDR} - ${newRoute.models[i].LAT} - ${newRoute.models[i].LNG} - 0 - ${newRoute.models[i].TEV}");
    }

//    var table = await db.rawQuery("SELECT MAX(id_tracker) AS id FROM Iot_Routes_Tracker");
//    int id = (table.first["id"] != null) ?  table.first["id"] + 1 : 1;
//
//    print("newRouteRowJson: id: ${id} - ${newRoute.models[0].IDR} - ${newRoute.models[0].LAT} - ${newRoute.models[0].LNG} - ${newRoute.models[0].TEV} - ");
/*

    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Iot_Routes_Tracker (id_tracker,id_route,latitude,longitude,altitude,time_event)"
            " VALUES (?,?,?,?,?,?)",
        [id, newRoute.IDR, newRoute.LAT, newRoute.LNG, "0.0", newRoute.TEV]);
    return raw;

*/
  }


  DropTable(String table) async {
    final db = await database;
    print("table: $table");
    var delete = await db.execute("DROP TABLE IF EXISTS $table ;");
    return delete;
  }

  newRouteRow(Routes newRoute) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id_tracker)+1 as id FROM Iot_Routes_Tracker");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Iot_Routes_Tracker (id_tracker,id_route,latitude,longitude,altitude,time_event)"
            " VALUES (?,?,?,?,?,?)",
        [id, newRoute.id_tracker, newRoute.id_route, newRoute.latitude, newRoute.longitude, newRoute.altitude, newRoute.time_event]);
    return raw;
  }


/*

  blockOrUnblock(Client client) async {
    final db = await database;
    Client blocked = Client(
        id: client.id,
        firstName: client.firstName,
        lastName: client.lastName,
        blocked: !client.blocked);
    var res = await db.update("Client", blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }



  updateClient(Client newClient) async {
    final db = await database;
    var res = await db.update("Client", newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  getClient(int id) async {
    final db = await database;
    var res = await db.query("Client", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }

  Future<List<Client>> getBlockedClients() async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    var res = await db.query("Client", where: "blocked = ? ", whereArgs: [1]);

    List<Client> list =
    res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    var res = await db.query("Client");
    List<Client> list =
    res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  deleteClient(int id) async {
    final db = await database;
    return db.delete("Client", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Client");
  }


*/
  updateRoute(Routes newRoute) async {
    final db = await database;
    var res = await db.update("Iot_Routes_Tracker", newRoute.toMap(),
        where: "id_tracker = ?", whereArgs: [newRoute.id_tracker]);
    return res;
  }

  getRoute(int id) async {
    final db = await database;
    var res = await db.query("Iot_Routes_Tracker", where: "id_tracker = ?", whereArgs: [id]);
    return res.isNotEmpty ? Routes.fromMap(res.first) : null;
  }


  Future<List<Routes>> getAllRoutes(int id) async {
    print("PASSATO getAllRoutes");
    final db = await database;
    var res = await db.query("Iot_Routes_Tracker", where: "id_route = ?", whereArgs: [id]);
    print('res.map ${res.asMap()}');
    List<Routes> list = res.isNotEmpty ? res.map((c) => Routes.fromMap(c)).toList() : [];
/*
    for (int i = 0; i < list.length; i++) {
      print('${list[i].time_event}');
    }
*/
    return list;
  }

  deleteRoute(int id) async {
    final db = await database;
    return db.delete("Iot_Routes_Tracker", where: "id_tracker = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete from Iot_Routes_Tracker");

  }
  countRow() async {
    final db = await database;
    var numRow = await db.rawQuery("SELECT COUNT(id_tracker) AS RowNum from Iot_Routes_Tracker");
    int RowNum = numRow.first["RowNum"];
    print('RowNum: $RowNum');
  }
}