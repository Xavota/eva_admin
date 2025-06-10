import 'dart:convert';

import 'package:medicare/db_manager.dart';
import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/model/temp_patient_model.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:flutter/services.dart';


class DateModel extends IdentifierModel {
  DateModel(super.id, this.owner, this.date, this.phoneNumber, this.tempPatient, this.realPatient);

  final DoctorModel? owner;
  final DateTime date;
  final String phoneNumber;
  final TempPatientModel? tempPatient;
  final PatientListModel? realPatient;


  static Future<DateModel> fromJSON(Map<String, dynamic> json) async {
    JSONDecoder jsonDecoder = JSONDecoder(json);

    final ownerNumber = jsonDecoder.getString('doctorOwner');
    final owner = (await DBManager.instance!.doctors)?.firstWhere((e) => e.userNumber == ownerNumber);
    DateTime date = jsonDecoder.getDateTime('date');
    String phoneNumber = jsonDecoder.getString('phoneNumber');

    String userNumber = jsonDecoder.getString('userNumber');

    TempPatientModel? tempPatient;
    PatientListModel? realPatient;
    if (userNumber.isNotEmpty) {
      realPatient = (await DBManager.instance!.patients[ownerNumber])!.firstWhere((e) => e.userNumber == userNumber);
    }
    else {
      final Map<String, dynamic> tempInfo = {};
      tempInfo["id"] = jsonDecoder.getInt('temp_id');
      tempInfo["fullName"] = jsonDecoder.getString('temp_fullName');
      tempInfo["phoneNumber"] = jsonDecoder.getString('temp_phoneNumber');
      tempInfo["consultReasons"] = jsonDecoder.getString('temp_consultReasons');

      tempPatient = TempPatientModel.fromJSON(tempInfo);
    }

    return DateModel(jsonDecoder.getId, owner, date, phoneNumber, tempPatient, realPatient);
  }

  static Future<List<DateModel>> listFromJSON(List<dynamic> list) async {
    return await Future.wait(list.map((e) => DateModel.fromJSON(e)));
  }

  static List<DateModel>? _dummyList;

  static Future<List<DateModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = await listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/date_data.json');
  }
}
