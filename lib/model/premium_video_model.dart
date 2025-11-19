import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/premium_parent_model.dart';
import 'package:flutter/services.dart';

class PremiumVideoModel extends PremiumParentModel{
  final String tile;
  final bool free;
  final String frontPage;
  final String embed;

  PremiumVideoModel(super.id, this.tile, this.free, this.frontPage, this.embed);

  static PremiumVideoModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String tile = jsonDecoder.getString('title');
    bool free = jsonDecoder.getInt('free') == 1;
    String frontPage = jsonDecoder.getString('frontPage');
    String embed = jsonDecoder.getString('embed');

    return PremiumVideoModel(jsonDecoder.getId, tile, free, frontPage, embed);
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