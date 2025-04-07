import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Gender {
  male,
  female;

  const Gender();
}

enum BloodType {
  APlus,
  AMinus,
  BPlus,
  BMinus,
  ABPlus,
  ABMinus,
  OPlus,
  OMinus,
}

extension BloodTypeExtension on BloodType {
  String get name {
    switch (this) {
      case BloodType.APlus:
        return 'A+';
      case BloodType.AMinus:
        return 'A-';
      case BloodType.BPlus:
        return 'B+';
      case BloodType.BMinus:
        return 'B-';
      case BloodType.ABPlus:
        return 'AB+';
      case BloodType.ABMinus:
        return 'AB-';
      case BloodType.OPlus:
        return 'O+';
      case BloodType.OMinus:
        return 'O-';
    }
  }
}

class PatientAddController extends MyController {
  Gender gender = Gender.male;
  BloodType bloodType = BloodType.APlus;
  MyFormValidator basicValidator = MyFormValidator();
  DateTime? selectedDate;

  void onChangeGender(Gender? value) {
    gender = value ?? gender;
    update();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }
}
