import 'package:flutter/material.dart';


import 'package:medicare/db_manager.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';


//import 'package:blix_essentials/blix_essentials.dart';


class SecretaryAddController extends MyController {
  final manager = DBManager.instance!;

  List<GlobalKey<FormState>> formKeys = [];
  MyFormValidator basicValidator = MyFormValidator();

  bool loading = false;

  String replaceAlertText = "Usted ya tiene a alguien registrado como secretari@"
      " en el sistema. Registrar a alguien nuevo reemplazará al anterior."
      "\n¿Quiere registrar igualmente?";


  @override
  void onInit() {
    basicValidator.addField(
      'userNumber', required: true, label: "Número de usuario",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'pin', required: true, label: "NIP",
      validators: [MyIntegerValidator(exactLength: 4)],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'fullName', required: true, label: "Nombre completo",
      controller: TextEditingController(),
    );

    calculateUserID();

    super.onInit();
  }


  void clearForm() {
    basicValidator.getController('pin')!.text = "";
    basicValidator.getController('fullName')!.text = "";

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


  Future<String> calculateUserID() async {
    final lastID = manager.getSecretaryID(AuthService.loggedUserNumber);
    basicValidator.getController("userNumber")!.text = lastID;
    update();
    return lastID;
  }

  Future<bool?> checkExistence() async {
    return manager.isSecretaryRegistered(AuthService.loggedUserNumber);
  }

  Future<String?> onRegister([bool doUpdate = false]) async {
    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      update();
      Map<String, String>? errors;
      if (doUpdate) {
        errors = await DBManager.instance!.updateSecretary(
          basicValidator.getData(),
        );
      }
      else {
        errors = await DBManager.instance!.registerSecretary(
          basicValidator.getData(), AuthService.loggedUserNumber,
        );
      }
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