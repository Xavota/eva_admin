import 'package:flutter/material.dart';

import 'package:get/get.dart';


import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

import 'package:medicare/helpers/extention/date_time_extention.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/secretary_model.dart';
import 'package:medicare/model/patient_list_model.dart';


import 'package:blix_essentials/blix_essentials.dart';


class DateAddController extends MyController {
  final manager = DBManager.instance!;

  List<GlobalKey<FormState>> formKeys = [];
  MyFormValidator basicValidator = MyFormValidator();

  bool loading = false;

  List<PatientListModel> patients = [];

  PatientListModel? selectedPatient;

  bool tempPatient = false;
  DateTime? selectedDate;
  List<ConsultationReason> consultationReasons = [];


  @override
  void onInit() {
    updatePatientsInfo();

    basicValidator.addField(
      'phoneNumber', required: true, label: "Número de teléfono",
      controller: TextEditingController(),
      validators: [MyIntegerValidator(exactLength: 10)],
    );

    basicValidator.addField(
      'tempFullName', label: "Número de teléfono",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'tempPhoneNumber', label: "Número de teléfono",
      controller: TextEditingController(),
      validators: [MyIntegerValidator(exactLength: 10)],
    );

    super.onInit();
  }


  Future<void> updatePatientsInfo() async {
    patients = await manager.patients[(AuthService.loggedUserData as SecretaryModel).owner]?? [];
    update();
  }


  void clearForm() {
    selectedPatient = null;
    basicValidator.getController('phoneNumber')!.text = "";
    basicValidator.getController('tempFullName')!.text = "";
    basicValidator.getController('tempPhoneNumber')!.text = "";
    tempPatient = false;
    selectedDate = null;
    consultationReasons = [];

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

  void onChangeTempPatient(bool? value) {
    tempPatient = value ?? tempPatient;
    //basicValidator.onChanged<Sex>('sex')(sex);
    update();
  }

  void onChangeSelectedPatient(PatientListModel? value) {
    selectedPatient = value;
    update();
  }

  Future<void> pickDateTime() async {
    final lastDate = DateTime(2100, 12, 31, 23);
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!, initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), lastDate: lastDate,
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(context: Get.context!, initialTime: selectedDate?.timeOfDay ?? TimeOfDay.now());
      if (pickedTime != null) {
        selectedDate = pickedDate.applied(pickedTime);
        update();
      }
    }
  }

  void onConsultationChange(List<ConsultationReason> reasons) {
    consultationReasons = reasons;
    basicValidator.onChanged<List<ConsultationReason>>('tempConsultReasons')(consultationReasons);
    update();
  }

  void removeConsultation(ConsultationReason reason) {
    consultationReasons.remove(reason);
    basicValidator.onChanged<List<ConsultationReason>>('tempConsultReasons')(consultationReasons);
    Debug.log("Current consultation reasons: [${consultationReasons.map<String>((e) => e.name).toList().join(", ")}]", overrideColor: Colors.redAccent);
    update();
  }

  String? addExtraDataError(String name, bool condition, String errorMsg) {
    if (condition) {
      if (!basicValidator.errors.containsKey(name)) {
        basicValidator.addErrors({name : errorMsg});
      }
      Debug.log("$name not found", overrideColor: Colors.purpleAccent);
      return "Hay errores en algunos datos";
    }
    else {
      basicValidator.errors.remove(name);
    }
    return null;
  }

  bool dataIsEmpty(String name, Map<String, dynamic> data) {
    return !data.containsKey(name) || data[name] == null || data[name].isEmpty;
  }

  Future<String?> onRegister() async {
    String? validationError;

    final data = basicValidator.getData();

    validationError = addExtraDataError(
      'date',
      selectedDate == null,
      "Este campo es obligatorio",
    )?? validationError;

    if (tempPatient) {
      validationError = addExtraDataError(
        'tempFullName',
        dataIsEmpty('tempFullName', data),
        "Este campo es obligatorio",
      )?? validationError;
      validationError = addExtraDataError(
        'tempPhoneNumber',
        dataIsEmpty('tempPhoneNumber', data),
        "Este campo es obligatorio",
      )?? validationError;
      validationError = addExtraDataError(
        'tempConsultReasons',
        dataIsEmpty('tempConsultReasons', data),
        "Este campo es obligatorio",
      )?? validationError;
    }
    else {
      validationError = addExtraDataError(
        'userNumber',
        selectedPatient == null,
        "Este campo es obligatorio",
      )?? validationError;
    }

    if (basicValidator.validateForm()) {
      if (validationError != null) {
        update();
        return validationError;
      }

      if (!tempPatient) {
        data['userNumber'] = selectedPatient!.userNumber;
      }
      data['date'] = dbDateTimeFormatter.format(selectedDate!);

      loading = true;
      update();
      var errors = await DBManager.instance!.registerDate(data, (AuthService.loggedUserData as SecretaryModel).owner);
      if (errors != null) {
        if (errors.containsKey("server")) {
          validationError = errors["server"];
          errors.remove("server");
        }
        if (errors.isNotEmpty) {
          Debug.log("errors: $errors");
          basicValidator.addErrors(errors);
          basicValidator.validateForm();
          basicValidator.clearErrors();
          validationError = "Hay errores en algunos datos";

          if (errors.containsKey('userNumber')) {
            basicValidator.addError('userNumber', errors['userNumber']!);
          }
          if (errors.containsKey('date')) {
            basicValidator.addError('date', errors['date']!);
          }
        }
      }
      loading = false;
      update();
    }
    else {
      validationError = "Hay errores en algunos datos";
      update();
    }

    return validationError;
  }
}