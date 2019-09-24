
class JsonListRoute {
  final List<JsonModelRoute> models;

  JsonListRoute({
    this.models,
  });

  factory JsonListRoute.fromJson(List<dynamic> parsedJson) {

    List<JsonModelRoute> models = new List<JsonModelRoute>();
    models = parsedJson.map((i)=>JsonModelRoute.fromJson(i)).toList();

    return new JsonListRoute(
        models: models
    );
  }
}

class JsonModelRoute{

  String IDR;
  String LAT;
  String LNG;  
  String TEV;


  JsonModelRoute({
    this.IDR,
    this.LAT,
    this.LNG,
    this.TEV
  });

  factory JsonModelRoute.fromJson(Map<String, dynamic> json){

    return new JsonModelRoute(
        IDR: json['key_01'],
        LAT: json['key_02'],
        LNG: json['key_03'],
        TEV: json['key_04']
        
    );
  }
}

