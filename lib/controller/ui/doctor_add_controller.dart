import 'package:blix_essentials/blix_essentials.dart';
import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';

/*enum Gender {
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
}*/

class DoctorAddController extends MyController {
  final manager = DBManager.instance!;
  //Gender gender = Gender.male;
  //DateTime? selectedDate;
  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  int? _currentUserId;
  int? get currentUserId {
    if (_currentUserId == null) {
      calculateUserID();
    }
    return _currentUserId;
  }

  @override
  void onInit() {
    calculateUserID();

    /*basicValidator.addField(
      'userNumber', required: true, label: "Número de usuario",
      validators: [MyDoctorUserNumberValidator()],
      controller: TextEditingController(),
    );*/

    basicValidator.addField(
      'userNumber', required: true, label: "Número de Usuario",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'pin', required: true, label: "NIP",
      validators: [MyIntegerValidator(exactLength: 4)],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'professionalNumber', required: true, label: "Cédula Profesional",
      validators: [MyProNumberValidator()],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'fullName', required: true, label: "Nombre Completo",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'speciality', required: true, label: "Especialidad",
      controller: TextEditingController(),
    );

    super.onInit();
  }

  /*void onChangeGender(Gender? value) {
    gender = value ?? gender;
    update();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }*/

  Future<String?> onRegister() async {
    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await DBManager.instance!.registerDoctor(basicValidator.getData());
      if (errors != null) {
        if (errors.containsKey("server")) {
          validationError = errors["server"];
          errors.remove("server");
        }
        if (errors.isNotEmpty) {
          basicValidator.addErrors(errors);
          basicValidator.validateForm();
          basicValidator.clearErrors();
          validationError = "Hay errores en algunos datos";
        }
      }
      loading = false;
      update();
    }
    else {
      validationError = "Hay errores en algunos datos";
    }

    return validationError;
  }

  Future<int?> calculateUserID() async {
    _currentUserId = await manager.getLastDoctorID();
    basicValidator.getController("userNumber")!.text =
    _currentUserId == null ? "" : MyStringUtils.addZerosAtFront(_currentUserId!, lengthRequired: 4);
    update();
    return _currentUserId;
  }
}
