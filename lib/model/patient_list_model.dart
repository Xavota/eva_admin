import 'dart:convert';

import 'package:medicare/db_manager.dart';
import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/doctor_model.dart';
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
  PatientListModel(super.id, this.owner, this.userNumber, this.fullName, this.age,
      this.sex, this.weight, this.height, this.waist, this.job, this.birthDate,
      this.phoneNumber, this.status, this.consultationReasons, this.pdfName,
      this.weightGoal, this.waistGoal,
      this.diastolicPressureGoal, this.systolicPressureGoal, this.sugarGoal);

  final DoctorModel owner;
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


  final double? weightGoal;
  final double? waistGoal;
  final double? diastolicPressureGoal;
  final double? systolicPressureGoal;
  final double? sugarGoal;


  static Future<PatientListModel> fromJSON(Map<String, dynamic> json) async {
    JSONDecoder jsonDecoder = JSONDecoder(json);

    String ownerUserNumber = jsonDecoder.getString('owner');
    final owner = (await DBManager.instance!.doctors)!.firstWhere((e) => e.userNumber == ownerUserNumber);
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

    double? weightGoal = jsonDecoder.getDoubleOrNull('weightGoal');
    weightGoal = weightGoal == 0.0 ? null : weightGoal;
    double? waistGoal = jsonDecoder.getDoubleOrNull('waistGoal');
    waistGoal = waistGoal == 0.0 ? null : waistGoal;
    double? diastolicPressureGoal = jsonDecoder.getDoubleOrNull('diastolicPressureGoal');
    diastolicPressureGoal = diastolicPressureGoal == 0.0 ? null : diastolicPressureGoal;
    double? systolicPressureGoal = jsonDecoder.getDoubleOrNull('systolicPressureGoal');
    systolicPressureGoal = systolicPressureGoal == 0.0 ? null : systolicPressureGoal;
    double? sugarGoal = jsonDecoder.getDoubleOrNull('sugarGoal');
    sugarGoal = sugarGoal == 0.0 ? null : sugarGoal;

    return PatientListModel(
      jsonDecoder.getId, owner, userNumber, fullName, age,
      sex, weight, height, waist, job, birthDate, phoneNumber, status,
      consultationReasons, pdfName, weightGoal, waistGoal,
      diastolicPressureGoal, systolicPressureGoal, sugarGoal,
    );
  }

  static Future<List<PatientListModel>> listFromJSON(List<dynamic> list) async {
    return await Future.wait(list.map((e) => PatientListModel.fromJSON(e)));
  }

  static List<PatientListModel>? _dummyList;

  static Future<List<PatientListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = await listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/patient_list.json');
  }
}
