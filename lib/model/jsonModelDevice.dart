class JsonListDevice{
  final List<JsonModelDevice> models;

  JsonListDevice({
    this.models,
  });

  factory JsonListDevice.fromJson(List<dynamic> parsedJson) {

    List<JsonModelDevice> models = new List<JsonModelDevice>();
    models = parsedJson.map((i)=>JsonModelDevice.fromJson(i)).toList();

    return new JsonListDevice(
        models: models
    );
  }
}

class JsonModelDevice{
  String MacAddress;
  String Name;

  JsonModelDevice({
    this.MacAddress,
    this.Name
  });

  factory JsonModelDevice.fromJson(Map<String, dynamic> json){
    return new JsonModelDevice(
        MacAddress: json['Tab_00'],
        Name: json['Tab_01']
    );
  }
}