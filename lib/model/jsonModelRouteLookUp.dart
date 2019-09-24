
class JsonListRouteLookUp {
  final List<JsonModelRouteLookUp> modelsLookUp;

  JsonListRouteLookUp({
    this.modelsLookUp,
  });

  factory JsonListRouteLookUp.fromJson(List<dynamic> parsedJson) {

    List<JsonModelRouteLookUp> modelsLookUp = new List<JsonModelRouteLookUp>();
    modelsLookUp = parsedJson.map((i)=>JsonModelRouteLookUp.fromJson(i)).toList();

    return new JsonListRouteLookUp(
        modelsLookUp: modelsLookUp
    );
  }
}

class JsonModelRouteLookUp{

  String IDL;
  String IDR;
  String NAM;
  String DES;


  JsonModelRouteLookUp({
    this.IDL,
    this.IDR,
    this.NAM,
    this.DES
  });

  factory JsonModelRouteLookUp.fromJson(Map<String, dynamic> jsonLookUp){
    return new JsonModelRouteLookUp(


        IDL: jsonLookUp['key_01'],
        IDR: jsonLookUp['key_02'],
        NAM: jsonLookUp['key_03'],
        DES: jsonLookUp['key_04']
    );
  }
}

