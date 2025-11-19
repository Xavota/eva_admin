import 'dart:convert';

import 'package:medicare/db_manager.dart';
import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:flutter/services.dart';


class StudyModel extends IdentifierModel {
  StudyModel(super.id, this.owner, this.creationDate, this.description, this.pdf, this.patientAdded, this.images);

  final PatientListModel owner;
  final DateTime creationDate;
  final String description;
  final String pdf;
  final bool patientAdded;
  final List<String> images;


  static Future<StudyModel> fromJSON(Map<String, dynamic> json) async {
    JSONDecoder jsonDecoder = JSONDecoder(json);

    final ownerNumber = jsonDecoder.getString('patientNumber');
    final owner = (await DBManager.instance!.patients.getFromNumber(ownerNumber))!;
    DateTime creationDate = jsonDecoder.getDateTime('creationDate');
    String description = jsonDecoder.getString('description');
    String pdf = jsonDecoder.getString('pdf');
    bool patientAdded = jsonDecoder.getInt('patientAdded') == 1;
    List<String> images = jsonDecoder.getObjectList<String>('images');

    return StudyModel(jsonDecoder.getId, owner, creationDate, description, pdf, patientAdded, images);
  }

  static Future<List<StudyModel>> listFromJSON(List<dynamic> list) async {
    return await Future.wait(list.map((e) => StudyModel.fromJSON(e)));
  }

  static List<StudyModel>? _dummyList;

  static Future<List<StudyModel>> get dummyList async {
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
