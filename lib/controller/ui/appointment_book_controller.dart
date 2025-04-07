import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Gender {
  male,
  female;

  const Gender();
}

class AppointmentBookController extends MyController {
  Gender gender = Gender.male;
  DateTime? selectedDate;
  TimeOfDay? fromSelectedTime;
  TimeOfDay? toSelectedTime;
  MyFormValidator basicValidator = MyFormValidator();

  String selectedConsultingDoctor = 'Bernardo james';

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
        context: Get.context!, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }

  Future<void> fromPickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: Get.context!, initialTime: fromSelectedTime ?? TimeOfDay.now());
    if (picked != null && picked != fromSelectedTime) {
      fromSelectedTime = picked;
      update();
    }
  }

  Future<void> toPickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: Get.context!, initialTime: toSelectedTime ?? TimeOfDay.now());
    if (picked != null && picked != toSelectedTime) {
      toSelectedTime = picked;
      update();
    }
  }

  void onChangeGender(Gender? value) {
    gender = value ?? gender;
    update();
  }

  void onSelectedConsultingDoctor(String value) {
    selectedConsultingDoctor = value;
    update();
  }

  void submit() {
    Get.toNamed('/admin/appointment_scheduling');
  }
}
