import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';

import 'package:medicare/helpers/utils/context_instance.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:flutter/material.dart';

import 'package:medicare/db_manager.dart';

class AdminDoctorAddData {}


class AdminDoctorAddController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminDoctorAddData();
      contextInstance.addFormKey(index, "form");
      basicValidator.formKey = contextInstance.getFormKey(index, "form")!;
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeFormKey(index, "form");
      final prevFormKey = contextInstance.getPrevFormKey(index - 1, "form");
      if (prevFormKey != null) basicValidator.formKey = prevFormKey;
    },
  );

  Map<int, AdminDoctorAddData> data = {};

  @override
  void onInit() {
    calculateUserID();

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

  void /**/disposeFormKey(GlobalKey<FormState> key) {
    if (formKeys.contains(key)) {
      formKeys.remove(key);
    }
    basicValidator.formKey = formKeys.isNotEmpty ? formKeys.last : GlobalKey();
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
