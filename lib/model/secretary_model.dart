import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:flutter/services.dart';

class SecretaryModel extends IdentifierModel{
  final String userNumber;
  final String owner;
  final String fullName;

  SecretaryModel(super.id, this.userNumber, this.owner, this.fullName);

  static SecretaryModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String userNumber = jsonDecoder.getString('number');
    String owner = jsonDecoder.getString('owner');
    String fullName = jsonDecoder.getString('fullName');

    return SecretaryModel(jsonDecoder.getId, userNumber, owner, fullName);
  }

  static List<SecretaryModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => SecretaryModel.fromJSON(e)).toList();
  }

  static List<SecretaryModel>? _dummyList;

  static Future<List<SecretaryModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/secretary_data.json');
  }
}