
class JsonList {
  final List<JsonModel> models;

  JsonList({
    this.models,
  });

  factory JsonList.fromJson(List<dynamic> parsedJson) {

    List<JsonModel> models = new List<JsonModel>();
    models = parsedJson.map((i)=>JsonModel.fromJson(i)).toList();

    return new JsonList(
        models: models
    );
  }
}

class JsonModel{
  String DBT;
  String CNT;
  String TMP;
  String BTT;
  String HMD;
  String ALM;
  String LED;
  String CON;



  JsonModel({
    this.DBT,
    this.CNT,
    this.TMP,
    this.HMD,
    this.BTT,
    this.ALM,
    this.LED,
    this.CON
  });

  factory JsonModel.fromJson(Map<String, dynamic> json){
    return new JsonModel(
        DBT: json['key_00'],
        CNT: json['key_01'],
        TMP: json['key_02'],
        HMD: json['key_03'],
        BTT: json['key_04'],
        ALM: json['key_05'],
        LED: json['key_06'],
        CON: json['key_07']
    );
  }
}

