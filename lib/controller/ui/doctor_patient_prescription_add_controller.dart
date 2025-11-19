import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';

import 'package:medicare/model/prescription_model.dart';
import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientPrescriptionAddController extends MyController {
  final manager = DBManager.instance!;

  bool loading = false;

  List<GlobalKey<FormState>> formKeys = [];
  MyFormValidator basicValidator = MyFormValidator();

  PatientListModel? selectedPatient;
  int patientIndex = -1;


  Future<void> updatePatientInfo(int index) async {
    patientIndex = index;
    final patient = await manager.patients[AuthService.loggedUserNumber];
    if (patient == null) return;
    selectedPatient = patient[patientIndex];
  }

  @override
  void onInit() {
    super.onInit();

    basicValidator.addField(
      'plainText', required: true, label: "Este campo",
      controller: TextEditingController(),
    );
  }


  void clearForm() {
    basicValidator.getController('plainText')!.text = "";

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
      var errors = await DBManager.instance!.registerPrescription(basicValidator.getData(), selectedPatient!.userNumber);
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
