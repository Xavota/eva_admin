import 'package:flutter/material.dart';

import 'package:get/get.dart';


import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

import 'package:medicare/helpers/utils/context_instance.dart';

import 'package:medicare/helpers/extention/date_time_extention.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/secretary_model.dart';
import 'package:medicare/model/patient_list_model.dart';


import 'package:blix_essentials/blix_essentials.dart';

class SecretaryDateAddData {
  List<PatientListModel> patients = [];

  PatientListModel? selectedPatient;

  bool tempPatient = false;
  DateTime? selectedDate;
  List<ConsultationReason> consultationReasons = [];
}


class SecretaryDateAddController extends MyController
{
  SecretaryDateAddController();

  final manager = DBManager.instance!;

  MyFormValidator basicValidator = MyFormValidator();

  bool loading = false;

  // TODO: PARECE QUE EL [update] le vale y actualiza todas las pantallas, sin importar si están activas o no.
  // Hay una forma de arreglarlo, que es tener ids diferentes para cada pantalla y mandar en el [update] el id de la pantalla activa,
  // pero como al crear la pantalla, no hay un controller para usar, no se puede hacer eso desde el controller.
  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      Debug.log("onInstanceAdded", overrideColor: Colors.green);
      data[index] = SecretaryDateAddData();
      contextInstance.addFormKey(index, "form");
      basicValidator.formKey = contextInstance.getFormKey(index, "form")!;
    },
    onInstanceRemoved: (index) {
      Debug.log("onInstanceRemoved", overrideColor: Colors.green);
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeFormKey(index, "form");
      final prevFormKey = contextInstance.getPrevFormKey(index - 1, "form");
      if (prevFormKey != null) basicValidator.formKey = prevFormKey;
    },
  );

  Map<int, SecretaryDateAddData> data = {};


  @override
  void onInit() {
    super.onInit();

    basicValidator.addField(
      'phoneNumber', required: true, label: "Número de teléfono",
      controller: TextEditingController(),
      validators: [MyIntegerValidator(exactLength: 10)],
    );

    basicValidator.addField(
      'tempFullName', label: "Nombre completo",
      controller: TextEditingController(),
    );
  }


  Future<void> updatePatientsInfo(int instanceIndex) async {
    data[instanceIndex]!.patients = await manager.patients[(AuthService.loggedUserData as SecretaryModel).owner]?? [];
    contextInstance.doUpdate(instanceIndex);
  }


  /*void getOffAll() {
    Get.offAllNamed('/secretary/dates/list');
  }*/

  void doUpdate(int instanceIndex) {
    contextInstance.doUpdate(instanceIndex);
  }


  void clearForm(int instanceIndex) {
    data[instanceIndex]!.selectedPatient = null;
    basicValidator.getController('phoneNumber')!.text = "";
    basicValidator.getController('tempFullName')!.text = "";
    data[instanceIndex]!.tempPatient = false;
    data[instanceIndex]!.selectedDate = null;
    data[instanceIndex]!.consultationReasons = [];

    basicValidator.clearErrors();

    contextInstance.doUpdate(instanceIndex);
  }


  void onChangeTempPatient(int instanceIndex, bool? value) {
    data[instanceIndex]!.tempPatient = value ?? data[instanceIndex]!.tempPatient;
    //basicValidator.onChanged<Sex>('sex')(sex);
    contextInstance.doUpdate(instanceIndex);
  }

  void onChangeSelectedPatient(int instanceIndex, PatientListModel? value) {
    data[instanceIndex]!.selectedPatient = value;
    contextInstance.doUpdate(instanceIndex);
  }

  Future<void> pickDateTime(int instanceIndex) async {
    final lastDate = DateTime(2100, 12, 31, 23);
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!, initialDate: data[instanceIndex]!.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), lastDate: lastDate,
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(context: Get.context!, initialTime: data[instanceIndex]!.selectedDate?.timeOfDay ?? TimeOfDay.now());
      if (pickedTime != null) {
        data[instanceIndex]!.selectedDate = pickedDate.applied(pickedTime);
        contextInstance.doUpdate(instanceIndex);
      }
    }
  }

  void onConsultationChange(int instanceIndex, List<ConsultationReason> reasons) {
    data[instanceIndex]!.consultationReasons = reasons;
    basicValidator.onChanged<List<ConsultationReason>>('tempConsultReasons')(data[instanceIndex]!.consultationReasons);
    contextInstance.doUpdate(instanceIndex);
  }

  void removeConsultation(int instanceIndex, ConsultationReason reason) {
    data[instanceIndex]!.consultationReasons.remove(reason);
    basicValidator.onChanged<List<ConsultationReason>>('tempConsultReasons')(data[instanceIndex]!.consultationReasons);
    Debug.log("Current consultation reasons: [${data[instanceIndex]!.consultationReasons.map<String>((e) => e.name).toList().join(", ")}]", overrideColor: Colors.redAccent);
    contextInstance.doUpdate(instanceIndex);
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

  Future<String?> onRegister(int instanceIndex) async {
    String? validationError;

    final validatorData = basicValidator.getData();

    validationError = addExtraDataError(
      'date',
      data[instanceIndex]!.selectedDate == null,
      "Este campo es obligatorio",
    )?? validationError;

    if (data[instanceIndex]!.tempPatient) {
      validationError = addExtraDataError(
        'tempFullName',
        dataIsEmpty('tempFullName', validatorData),
        "Este campo es obligatorio",
      )?? validationError;
      validationError = addExtraDataError(
        'tempConsultReasons',
        dataIsEmpty('tempConsultReasons', validatorData),
        "Este campo es obligatorio",
      )?? validationError;
    }
    else {
      validationError = addExtraDataError(
        'userNumber',
        data[instanceIndex]!.selectedPatient == null,
        "Este campo es obligatorio",
      )?? validationError;
    }

    Debug.log("basicValidator formKey: ${basicValidator.formKey}");
    Debug.log("contextInstance formKey: ${contextInstance.getFormKey(instanceIndex, "form")}");
    if (basicValidator.validateForm()) {
      if (validationError != null) {
        contextInstance.doUpdate(instanceIndex);
        return validationError;
      }

      if (!data[instanceIndex]!.tempPatient) {
        validatorData['userNumber'] = data[instanceIndex]!.selectedPatient!.userNumber;
      }
      validatorData['date'] = dbDateTimeFormatter.format(data[instanceIndex]!.selectedDate!);

      loading = true;
      contextInstance.doUpdate(instanceIndex);
      var errors = await DBManager.instance!.registerDate(validatorData, (AuthService.loggedUserData as SecretaryModel).owner);
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
      contextInstance.doUpdate(instanceIndex);
    }
    else {
      validationError = "Hay errores en algunos datos";
      contextInstance.doUpdate(instanceIndex);
    }

    return validationError;
  }
}