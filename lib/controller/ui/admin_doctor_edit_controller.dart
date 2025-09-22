import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
//import 'package:medicare/helpers/widgets/my_text_utils.dart';
import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
//import 'package:get/get.dart';

import 'package:medicare/db_manager.dart';
//import 'package:blix_essentials/blix_essentials.dart';

enum Gender {
  male,
  female;

  const Gender();
}

enum Department {
  kOrthopedic,
  kRadiology,
  kDentist,
  kNeurology;

  const Department();
}

class AdminDoctorEditController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  bool loading = false;

  MyFormValidator basicValidator = MyFormValidator();
  DoctorModel? selectedDoctor;

  @override
  void onInit() {
    basicValidator.addField(
      'userNumber', required: true, label: "Número de usuario",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'pin', label: "NIP",
      validators: [MyIntegerValidator(exactLength: 4)],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'professionalNumber', required: true, label: "Cédula Profesional",
      validators: [MyIntegerValidator(exactLength: 8)],
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


  void clearPin() {
    basicValidator.getController('pin')!.text = "";
  }


  Future<void> updateDoctorInfo(int index) async {
    final docs = await manager.doctors;
    if (docs == null) return;
    selectedDoctor = docs[index];

    basicValidator.getController("userNumber")!.text = selectedDoctor!.userNumber;
    basicValidator.getController("professionalNumber")!.text = selectedDoctor!.professionalNumber.toString();
    basicValidator.getController("fullName")!.text = selectedDoctor!.fullName.toString();
    basicValidator.getController("speciality")!.text = selectedDoctor!.speciality.toString();

    update();
  }

  Future<String?> onUpdate() async {
    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await DBManager.instance!.updateDoctor(basicValidator.getData());
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


  GlobalKey<FormState> addNewFormKey() {
    formKeys.add(GlobalKey());
    basicValidator.formKey = formKeys.last;
    return basicValidator.formKey;
  }

  void disposeFormKey(GlobalKey<FormState> key) {
    if (formKeys.contains(key)) {
      formKeys.remove(key);
    }
    basicValidator.formKey = formKeys.last;
  }
}
