import 'package:flutter/material.dart';

import 'package:get/get.dart';


import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/daily_record_model.dart';


import 'package:blix_essentials/blix_essentials.dart';


class PatientDalyRecordController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  bool loading = false;


  MyFormValidator basicValidator = MyFormValidator();

  EmotionalState? emotionalState;
  bool? medications;
  bool? exercise;


  Future<void> getTodayRecord() async {
    clearForm();

    final records = await manager.getPatientDailyRecords(AuthService.loggedUserNumber, ofToday: true);

    if ((records?? []).isEmpty) return;

    final record = records![0];

    basicValidator.getController('weight')!.text = record.weight?.toString()?? "";
    basicValidator.getController('waist')!.text = record.waist?.toString()?? "";
    basicValidator.getController('systolicBloodPressure')!.text = record.systolicBloodPressure?.toString()?? "";
    basicValidator.getController('diastolicBloodPressure')!.text = record.diastolicBloodPressure?.toString()?? "";
    basicValidator.getController('sugarLevel')!.text = record.sugarLevel?.toString()?? "";
    basicValidator.getController('sleepTime')!.text = record.sleepTime?.toString()?? "";

    emotionalState = record.emotionalState;
    basicValidator.onChanged<EmotionalState?>('emotionalState')(emotionalState);
    medications = record.medications;
    basicValidator.onChanged<bool?>('medications')(medications);
    exercise = record.exercise;
    basicValidator.onChanged<bool?>('exercise')(exercise);

    update();
  }


  @override
  void onInit() {
    basicValidator.addField(
      'weight', label: "Peso",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'waist', label: "Cintura",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'systolicBloodPressure', label: "Presión Arterial Sistólica",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'diastolicBloodPressure', label: "Presión Arterial Diastólica",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'sugarLevel', label: "Azucar en Sangre",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'sleepTime', label: "Horas de Sueño",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 2, maxLengthAfterPoint: 2)],
    );

    emotionalState = null;
    basicValidator.onChanged<EmotionalState?>('emotionalState')(emotionalState);
    medications = null;
    basicValidator.onChanged<bool?>('medications')(medications);
    exercise = null;
    basicValidator.onChanged<bool?>('exercise')(exercise);

    super.onInit();
  }


  void clearForm() {
    basicValidator.getController('weight')!.text = "";
    basicValidator.getController('waist')!.text = "";
    basicValidator.getController('systolicBloodPressure')!.text = "";
    basicValidator.getController('diastolicBloodPressure')!.text = "";
    basicValidator.getController('sugarLevel')!.text = "";
    basicValidator.getController('sleepTime')!.text = "";

    emotionalState = null;
    basicValidator.onChanged<EmotionalState?>('emotionalState')(emotionalState);
    medications = null;
    basicValidator.onChanged<bool?>('medications')(medications);
    exercise = null;
    basicValidator.onChanged<bool?>('exercise')(exercise);

    //update();
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


  void onChangeEmotionalState(EmotionalState? value) {
    emotionalState = value;
    basicValidator.onChanged<EmotionalState?>('emotionalState')(emotionalState);
    update();
  }

  void onChangeMedications(bool? value) {
    medications = value;
    basicValidator.onChanged<bool?>('medications')(medications);
    update();
  }

  void onChangeExercise(bool? value) {
    exercise = value;
    basicValidator.onChanged<bool?>('exercise')(exercise);
    update();
  }


  Future<String?> onSave() async {
    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      update();

      var errors = await DBManager.instance!.saveDailyRecord(basicValidator.getData(), AuthService.loggedUserNumber);
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