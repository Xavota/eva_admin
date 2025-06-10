import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:flutter/services.dart';



enum Sex {
  male,
  female;

  const Sex();
}

extension SexExtension on Sex {
  String get name {
    switch (this) {
      case Sex.male:
        return 'M';
      case Sex.female:
        return 'F';
    }
  }
  String get fullName {
    switch (this) {
      case Sex.male:
        return 'Masculino';
      case Sex.female:
        return 'Femenino';
    }
  }
}


/*enum BloodType {
  kAPlus,
  kAMinus,
  kBPlus,
  kBMinus,
  kABPlus,
  kABMinus,
  kOPlus,
  kOMinus,
}

extension BloodTypeExtension on BloodType {
  String get name {
    switch (this) {
      case BloodType.kAPlus:
        return 'A+';
      case BloodType.kAMinus:
        return 'A-';
      case BloodType.kBPlus:
        return 'B+';
      case BloodType.kBMinus:
        return 'B-';
      case BloodType.kABPlus:
        return 'AB+';
      case BloodType.kABMinus:
        return 'AB-';
      case BloodType.kOPlus:
        return 'O+';
      case BloodType.kOMinus:
        return 'O-';
    }
  }
}*/


enum ConsultationReason {
  kDiabetes,
  kObesity,
  kThyroid,
  kMenopause,
  kOvary,
  kCholesterol,
  kBeHealthy
}

extension ConsultationReasonExtension on ConsultationReason {
  String get name {
    switch (this) {
      case ConsultationReason.kDiabetes:
        return 'Diabetes';
      case ConsultationReason.kObesity:
        return 'Obesidad';
      case ConsultationReason.kThyroid:
        return 'Tiroides';
      case ConsultationReason.kMenopause:
        return 'Menopausia';
      case ConsultationReason.kOvary:
        return 'Ovario poliquístico';
      case ConsultationReason.kCholesterol:
        return 'Colesterol y triglicéridos';
      case ConsultationReason.kBeHealthy:
        return 'Solo busco estar sano';
    }
  }

  int get dbid {
    return index + 1;
  }

  static ConsultationReason getFromDBID(int dbid) {
    return ConsultationReason.values[dbid - 1];
  }
}


class PatientListModel extends IdentifierModel {
  PatientListModel(super.id, this.userNumber, this.fullName, this.age,
      this.sex, this.weight, this.height, this.waist, this.job, this.birthDate,
      this.phoneNumber, this.status, this.consultationReasons, this.pdfName);

  final String userNumber;
  final String fullName;
  final int age;
  final Sex sex;
  final double weight;
  final double height;
  final double waist;
  final String job;
  final DateTime birthDate;
  final String phoneNumber;
  final bool status;
  final List<ConsultationReason> consultationReasons;

  final String pdfName;


  static PatientListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String userNumber = jsonDecoder.getString('number');
    String fullName = jsonDecoder.getString('fullName');
    int age = jsonDecoder.getInt('age');
    Sex sex = Sex.values[jsonDecoder.getInt('sex')];
    double weight = jsonDecoder.getDouble('weight');
    double height = jsonDecoder.getDouble('height');
    double waist = jsonDecoder.getDouble('waist');
    String job = jsonDecoder.getString('job');
    DateTime birthDate = jsonDecoder.getDateTime('birthDate');
    String phoneNumber = jsonDecoder.getString('phoneNumber');
    bool status = jsonDecoder.getInt('status') == 1;
    List<ConsultationReason> consultationReasons = jsonDecoder
        .getString('consultReasons')
        .split(",")
        .map<int>((e) => int.parse(e))
        .map<ConsultationReason>((e) => ConsultationReasonExtension.getFromDBID(e))
        .toList();

    String pdfName = jsonDecoder.getString('pdfName');

    return PatientListModel(jsonDecoder.getId, userNumber, fullName, age, sex,
      weight, height, waist, job, birthDate, phoneNumber, status, consultationReasons, pdfName);
  }

  static List<PatientListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => PatientListModel.fromJSON(e)).toList();
  }

  static List<PatientListModel>? _dummyList;

  static Future<List<PatientListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/patient_list.json');
  }
}
