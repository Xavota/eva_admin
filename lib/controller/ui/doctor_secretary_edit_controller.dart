import 'package:flutter/material.dart';

import 'package:get/get.dart';


import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/secretary_model.dart';


import 'package:blix_essentials/blix_essentials.dart';


class DoctorSecretaryEditController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  bool loading = false;

  MyFormValidator basicValidator = MyFormValidator();
  SecretaryModel? selectedSecretary;


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
      'fullName', required: true, label: "Nombre completo",
      controller: TextEditingController(),
    );

    super.onInit();
  }

  Future<void> updateSecretaryInfo() async {
    selectedSecretary = await manager.secretaries[AuthService.loggedUserNumber];
    if (selectedSecretary == null) return;

    basicValidator.getController("userNumber")!.text = selectedSecretary!.userNumber;
    basicValidator.getController("fullName")!.text = selectedSecretary!.fullName;

    update();
  }


  void clearPin() {
    basicValidator.getController('pin')!.text = "";
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


  Future<String?> onUpdate() async {
    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      update();

      var errors = await DBManager.instance!.updateSecretary(basicValidator.getData());
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
}