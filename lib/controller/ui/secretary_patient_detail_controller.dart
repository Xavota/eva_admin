import 'dart:typed_data';

import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

//import 'package:http_parser/http_parser.dart';

import 'package:medicare/app_constant.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/utils/my_utils.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/secretary_model.dart';

import 'package:medicare/db_manager.dart';


enum TimeType {
  kOneDay,
  kTwoDays,
  kFiveDays,
  kOneWeek,
  kTwoWeeks,
  kOneMonth,
  kTwoMonths,
  kThreeMonths,
  kSixMonths,
  kOneYear,
  kCustom
}

/// TODO: ESTOS TIEMPOS NO SÉ SI DEJARLOS FIJOS O QUE SI PONEN UN TIEMPO MEDIDO EN MESES DEPENDA DEL MES EN EL QUE ESTÉN.
/// TODO: PREGUNTAR DE ESTO DESPUÉS, PORQUE NO ES IMPORTANTE AHORITA.
extension TimeTypeExtension on TimeType {
  String get name {
    switch (this) {
      case TimeType.kOneDay:
        return "Un día";
      case TimeType.kTwoDays:
        return "Dos días";
      case TimeType.kFiveDays:
        return "Cinco días";
      case TimeType.kOneWeek:
        return "Una semana";
      case TimeType.kTwoWeeks:
        return "Dos semanas";
      case TimeType.kOneMonth:
        return "Un mes";
      case TimeType.kTwoMonths:
        return "Dos meses";
      case TimeType.kThreeMonths:
        return "Tres meses";
      case TimeType.kSixMonths:
        return "Seis meses";
      case TimeType.kOneYear:
        return "Un año";
      case TimeType.kCustom:
        return "Personalizado";
    }
  }

  Duration get realTime {
    switch (this) {
      case TimeType.kOneDay:
        return Duration(days: 1);
      case TimeType.kTwoDays:
        return Duration(days: 2);
      case TimeType.kFiveDays:
        return Duration(days: 5);
      case TimeType.kOneWeek:
        return Duration(days: 7);
      case TimeType.kTwoWeeks:
        return Duration(days: 14);
      case TimeType.kOneMonth:
        return Duration(days: 30);
      case TimeType.kTwoMonths:
        return Duration(days: 61);
      case TimeType.kThreeMonths:
        return Duration(days: 91);
      case TimeType.kSixMonths:
        return Duration(days: 182);
      case TimeType.kOneYear:
        return Duration(days: 365);
      case TimeType.kCustom:
        return Duration();
    }
  }
}


class SecretaryPatientDetailController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];
  MyFormValidator basicValidator = MyFormValidator();

  bool loading = false;

  SecretaryModel? _loggedInSecretary;

  PatientListModel? selectedPatient;
  SubscriptionStatus? subscriptionStatus;
  DateTime? subscriptionStarts;
  DateTime? subscriptionEnds;

  int patientIndex = -1;

  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));
  String cancelAlertText = "¿Segur@ que quiere cancelar la suscripción de este"
      " tratante?";


  DateTime subActivateStarts = DateTime.now();
  TimeType? subDurationType = TimeType.kOneDay;
  Duration? subCustomDuration;

  //Uint8List? pdfBytes;


  @override
  void onInit() {
    _loggedInSecretary = AuthService.loggedUserData as SecretaryModel?;

    basicValidator.addField(
      'startDate', required: true, label: "Fecha de Inicio",
      controller: TextEditingController(),
    );
    basicValidator.getController('startDate')!.text = dateFormatter.format(subActivateStarts);

    basicValidator.addField(
      'durationDays', label: "Duración en Días",
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'durationMonths', label: "Duración en Meses",
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'durationYears', label: "Duración en Años",
      controller: TextEditingController(),
    );

    super.onInit();
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


  Future<void> updatePatientInfo(int index) async {
    patientIndex = index;
    final patients = await manager.getPatients(doctorOwnerID: _loggedInSecretary!.owner);
    if (patients == null) return;
    selectedPatient = patients[patientIndex];

    final subInfo = await manager.getPatientSubStatus(selectedPatient!.userNumber);
    Debug.log("updatePatientInfo() => subInfo: $subInfo", overrideColor: Colors.purple);
    if (subInfo == null) return;
    subscriptionStatus = subInfo.$1;
    subscriptionStarts = subInfo.$2;
    subscriptionEnds = subInfo.$3;

    update();
  }

  /*void showPDFPreview(BuildContext context) {
    final pdfName = selectedPatient?.pdfName?? "";
    if (pdfName.isEmpty) return;

    final pdfURL = BlixDBManager.getUrl("uploads/pdf/$pdfName");
    launchUrl(Uri.parse(pdfURL));
  }*/


  Future<void> pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!, initialDate: subActivateStarts,
      firstDate: DateTime(1900, 1), lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null && picked != subActivateStarts) {
      subActivateStarts = picked;
      basicValidator.getController('startDate')!.text = dateFormatter.format(subActivateStarts);
      update();
    }
  }

  void changeDurationType(TimeType? type) {
    subDurationType = type;
    update();
  }

  void changeCustomDuration(int days, int months, int years) {
    if (days == 0 && months == 0 && years == 0) {
      subCustomDuration = null;
      update();
      return;
    }
    subCustomDuration = Duration(days: days + (months * (365 / 12)).round() + years * 365);
    update();
  }

  DateTime? getFinalSubDate() {
    if (subDurationType == null ||
        (subDurationType == TimeType.kCustom && subCustomDuration == null)) {
      return null;
    }
    final duration = subDurationType == TimeType.kCustom ? subCustomDuration! : subDurationType!.realTime;
    return subActivateStarts.add(duration);
  }


  Future<String?> activateSubscription() async {
    String? validationError;

    if (subDurationType == null) {
      basicValidator.errors['duration'] = "Este campo es obligatorio";
      validationError = "Hay errores en algunos datos";
    }
    else if (subDurationType == TimeType.kCustom && subCustomDuration == null) {
      basicValidator.errors['duration'] = "Este campo es obligatorio y no puede ser 0";
      validationError = "Hay errores en algunos datos";
    }
    else {
      basicValidator.errors.remove('duration');
    }

    if (basicValidator.validateForm()) {
      if (validationError != null) {
        update();
        return validationError;
      }

      loading = true;
      update();

      final duration = subDurationType == TimeType.kCustom ? subCustomDuration! : subDurationType!.realTime;
      var errors = await DBManager.instance!.activatePatientSub(
        selectedPatient!.userNumber, subActivateStarts, subActivateStarts.add(duration)
      );
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

  Future<String?> cancelSubscription() async {
    String? validationError;

    loading = true;
    update();

    final error = await DBManager.instance!.cancelPatientSub(
        selectedPatient!.userNumber
    );
    if (error != null) {
      validationError = error;
    }

    loading = false;
    update();

    return validationError;
  }
}