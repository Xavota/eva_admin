import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:flutter/services.dart';

class DoctorModel extends IdentifierModel{
  final String userNumber;
  final String fullName;
  final String professionalNumber;
  final String speciality;
  final bool status;

  DoctorModel(super.id,this.userNumber, this.fullName, this.professionalNumber, this.speciality, this.status);

  static DoctorModel fromJSON(Map<String,dynamic> json){
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String userNumber = jsonDecoder.getString('number');
    String fullName = jsonDecoder.getString('fullName');
    String professionalNumber = jsonDecoder.getString('proNumber');
    String speciality = jsonDecoder.getString('speciality');
    bool status = jsonDecoder.getInt('status') == 1;

    return DoctorModel(jsonDecoder.getId, userNumber, fullName, professionalNumber, speciality, status);
  }

  static List<DoctorModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => DoctorModel.fromJSON(e)).toList();
  }

  static List<DoctorModel>? _dummyList;

  static Future<List<DoctorModel>> get dummyList async {
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