import 'dart:convert';

Routes routesFromJson(String str) {
  final jsonData = json.decode(str);
  return Routes.fromMap(jsonData);
}

String routesToJson(Routes data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

/*
              "id_tracker INTEGER PRIMARY KEY,"
              "id_device INTEGER NOT NULL,"
              "id_route INTEGER NOT NULL,"
              "latitude REAL,"
              "longitude REAL,"
              "altitude REAL,"
              "time_event NUMERIC"

 */
class Routes {
  int id_tracker;
  int id_route;
  double latitude;
  double longitude;
  double altitude;
  String time_event;


  Routes({

    this.id_tracker,
    this.id_route,
    this.latitude,
    this.longitude,
    this.altitude,
    this.time_event,

  });

  factory Routes.fromMap(Map<String, dynamic> json) => new Routes(
    id_route: json["id_route"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    altitude: json["altitude"],
    time_event: json["time_event"],
  );

  Map<String, dynamic> toMap() => {
    "id_tracker": id_tracker,
    "id_route": id_route,
    "latitude": latitude,
    "longitude": longitude,
    "altitude": altitude,
    "time_event": time_event,
  };
}
