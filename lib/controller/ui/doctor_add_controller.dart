import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Gender {
  male,
  female;

  const Gender();
}

enum Department {
  Orthopedic,
  Radiology,
  Dentist,
  Neurology;

  const Department();
}

class DoctorAddController extends MyController {
  Gender gender = Gender.male;
  DateTime? selectedDate;
  MyFormValidator basicValidator = MyFormValidator();

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
