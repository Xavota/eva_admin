import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/premium_parent_model.dart';
import 'package:flutter/services.dart';

class PremiumPostModel extends PremiumParentModel{
  final String tile;
  final String description;
  final bool free;
  final List<String> images;

  PremiumPostModel(super.id, this.tile, this.description, this.free, this.images);

  static PremiumPostModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String tile = jsonDecoder.getString('title');
    String description = jsonDecoder.getString('description');
    bool free = jsonDecoder.getInt('free') == 1;
    List<String> images = jsonDecoder.getObjectList<String>('images');

    return PremiumPostModel(jsonDecoder.getId, tile, description, free, images);
  }

  static List<PremiumPostModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => PremiumPostModel.fromJSON(e)).toList();
  }

  static List<PremiumPostModel>? _dummyList;

  static Future<List<PremiumPostModel>> get dummyList async {
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