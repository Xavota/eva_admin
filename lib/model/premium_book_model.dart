import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/premium_parent_model.dart';
import 'package:flutter/services.dart';

class PremiumBookModel extends PremiumParentModel{
  final String tile;
  final String frontPage;
  final String book;

  PremiumBookModel(super.id, this.tile, this.frontPage, this.book);

  static PremiumBookModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String tile = jsonDecoder.getString('title');
    String frontPage = jsonDecoder.getString('frontPage');
    String book = jsonDecoder.getString('book');

    return PremiumBookModel(jsonDecoder.getId, tile, frontPage, book);
  }

  static List<PremiumBookModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => PremiumBookModel.fromJSON(e)).toList();
  }

  static List<PremiumBookModel>? _dummyList;

  static Future<List<PremiumBookModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/doctor_data.json');
  }
}