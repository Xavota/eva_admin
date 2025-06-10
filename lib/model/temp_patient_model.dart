import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:flutter/services.dart';


class TempPatientModel extends IdentifierModel {
  TempPatientModel(super.id, this.fullName, this.phoneNumber, this.consultationReasons);

  final String fullName;
  final String phoneNumber;
  final List<ConsultationReason> consultationReasons;


  static TempPatientModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String fullName = jsonDecoder.getString('fullName');
    String phoneNumber = jsonDecoder.getString('phoneNumber');
    List<ConsultationReason> consultationReasons = jsonDecoder
        .getString('consultReasons')
        .split(",")
        .map<int>((e) => int.parse(e))
        .map<ConsultationReason>((e) => ConsultationReasonExtension.getFromDBID(e))
        .toList();

    return TempPatientModel(jsonDecoder.getId, fullName, phoneNumber, consultationReasons);
  }

  static List<TempPatientModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => TempPatientModel.fromJSON(e)).toList();
  }

  static List<TempPatientModel>? _dummyList;

  static Future<List<TempPatientModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/temp_patient_list.json');
  }
}
