import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:flutter/services.dart';

class MonthlySubsModel extends IdentifierModel{
  final String doctorNumber;
  final String doctorName;
  final int subsCount;
  final int monthsCount;
  final bool payed;

  MonthlySubsModel(super.id,this.doctorNumber, this.doctorName, this.subsCount,
      this.monthsCount, this.payed);

  static MonthlySubsModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String doctorNumber = jsonDecoder.getString('doctorNumber');
    String doctorName = jsonDecoder.getString('doctorName');
    int subsCount = jsonDecoder.getInt('subsCount');
    int monthsCount = jsonDecoder.getInt('monthsCount');
    bool payed = jsonDecoder.getInt('payed') == 1;

    return MonthlySubsModel(jsonDecoder.getId, doctorNumber, doctorName, subsCount,
        monthsCount, payed);
  }

  static List<MonthlySubsModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => MonthlySubsModel.fromJSON(e)).toList();
  }

  static List<MonthlySubsModel>? _dummyList;

  static Future<List<MonthlySubsModel>> get dummyList async {
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