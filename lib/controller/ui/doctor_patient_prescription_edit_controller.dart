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


class DoctorPatientPrescriptionEditController extends MyController {
  final manager = DBManager.instance!;

  bool loading = false;

  List<GlobalKey<FormState>> formKeys = [];
  MyFormValidator basicValidator = MyFormValidator();

  PatientListModel? selectedPatient;
  int _patientIndex = -1;
  PrescriptionModel? selectedPrescription;
  int _prescriptionIndex = -1;


  Future<void> updateInfo(int patientIndex, int prescriptionIndex) async {
    _patientIndex = patientIndex;
    _prescriptionIndex = prescriptionIndex;
    final patients = await manager.patients[AuthService.loggedUserNumber];
    if (patients == null) return;
    selectedPatient = patients[patientIndex];
    final prescriptions = await manager.prescription[AuthService.loggedUserNumber][selectedPatient!.userNumber];
    if (prescriptions == null) return;
    selectedPrescription = prescriptions[_prescriptionIndex];

    basicValidator.getController('plainText')!.text = selectedPrescription!.plainText;
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


  Future<String?> onEdit() async {
    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await DBManager.instance!.editPrescription(basicValidator.getData(), selectedPrescription!.id);
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
