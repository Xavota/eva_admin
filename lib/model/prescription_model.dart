import 'dart:convert';

import 'package:medicare/db_manager.dart';
import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:flutter/services.dart';


class PrescriptionModel extends IdentifierModel {
  PrescriptionModel(super.id, this.owner, this.creationDate, this.plainText);

  final PatientListModel owner;
  final DateTime creationDate;
  final String plainText;


  static Future<PrescriptionModel> fromJSON(Map<String, dynamic> json) async {
    JSONDecoder jsonDecoder = JSONDecoder(json);

    final ownerNumber = jsonDecoder.getString('patientNumber');
    final owner = (await DBManager.instance!.patients.getFromNumber(ownerNumber))!;
    DateTime creationDate = jsonDecoder.getDateTime('creationDate');
    String plainText = jsonDecoder.getString('plainText');

    return PrescriptionModel(jsonDecoder.getId, owner, creationDate, plainText);
  }

  static Future<List<PrescriptionModel>> listFromJSON(List<dynamic> list) async {
    return await Future.wait(list.map((e) => PrescriptionModel.fromJSON(e)));
  }

  static List<PrescriptionModel>? _dummyList;

  static Future<List<PrescriptionModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = await listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/prescription_data.json');
  }
}
