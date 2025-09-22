import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';

import 'package:medicare/db_manager.dart';

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

class AdminDoctorAddController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  //Gender gender = Gender.male;
  //DateTime? selectedDate;
  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

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


  void clearForm() {
    basicValidator.getController('pin')!.text = "";
    basicValidator.getController('professionalNumber')!.text = "";
    basicValidator.getController('fullName')!.text = "";
    basicValidator.getController('speciality')!.text = "";

    update();
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

  Future<String?> calculateUserID() async {
    final lastID = await manager.getLastDoctorID();
    basicValidator.getController("userNumber")!.text = lastID?? "";
    update();
    return lastID;
  }
}
