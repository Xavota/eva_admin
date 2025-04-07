import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Gender {
  male,
  female;

  const Gender();
}

class AppointmentEditController extends MyController {
  Gender gender = Gender.male;
  TextEditingController firstNameTE = TextEditingController(text: "Andrea");
  TextEditingController lastNameTE = TextEditingController(text: "Buckland");
  TextEditingController mobileNumberTE = TextEditingController(text: "123 345 3454");
  TextEditingController emailTE = TextEditingController(text: "andrea@gmail.com");
  TextEditingController addressTE = TextEditingController(text: "Akshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016");
  TextEditingController treatmentTE = TextEditingController(text: "Prostate");
  DateTime? selectedDate = DateTime.now();
  TimeOfDay? fromSelectedTime = TimeOfDay(hour: 8, minute: 20);
  TimeOfDay? toSelectedTime = TimeOfDay(hour: 9, minute: 20);

  String selectedConsultingDoctor = 'Bernardo james';

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
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
