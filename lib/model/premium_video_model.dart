import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/premium_parent_model.dart';
import 'package:flutter/services.dart';

class PremiumVideoModel extends PremiumParentModel{
  final String tile;
  final String description;
  final List<String> images;

  PremiumVideoModel(super.id, this.tile, this.description, this.images);

  static PremiumVideoModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String tile = jsonDecoder.getString('title');
    String description = jsonDecoder.getString('description');
    List<String> images = jsonDecoder.getObjectList<String>('images');

    return PremiumVideoModel(jsonDecoder.getId, tile, description, images);
  }

  static List<PremiumVideoModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => PremiumVideoModel.fromJSON(e)).toList();
  }

  static List<PremiumVideoModel>? _dummyList;

  static Future<List<PremiumVideoModel>> get dummyList async {
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