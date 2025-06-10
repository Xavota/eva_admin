import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:flutter/services.dart';

class AdminModel extends IdentifierModel{
  final String name;
  final String email;

  AdminModel(super.id, this.name, this.email);

  static AdminModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String name = jsonDecoder.getString('name');
    String email = jsonDecoder.getString('email');

    return AdminModel(jsonDecoder.getId, name, email);
  }

  static List<AdminModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => AdminModel.fromJSON(e)).toList();
  }
}