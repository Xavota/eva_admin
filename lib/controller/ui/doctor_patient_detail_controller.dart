import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/material.dart';

//import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
//import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import 'package:medicare/helpers/utils/my_utils.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';

import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/daily_record_model.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


enum TimePeriod {
  kWeek,
  kMonth,
  k3Months,
  k6Months,
  kYear
}

extension TimePeriodExtension on TimePeriod {
  String get name {
    switch (this) {
      case TimePeriod.kWeek:
        return "Una semana";
      case TimePeriod.kMonth:
        return "Un mes";
      case TimePeriod.k3Months:
        return "3 meses";
      case TimePeriod.k6Months:
        return "6 meses";
      case TimePeriod.kYear:
        return "Un año";
    }
  }
}


class DoctorPatientDetailController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];
  MyFormValidator basicValidator = MyFormValidator();

  PatientListModel? selectedPatient;
  SubscriptionStatus? subscriptionStatus;
  DateTime? subscriptionStarts;
  DateTime? subscriptionEnds;

  int patientIndex = -1;

  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));


  String? pdfFileName;
  Uint8List? pdfFileData;
  String? pdfFileMimeType;


  int calendarCurrentMonth = -1;
  int calendarCurrentYear = -1;

  TimePeriod historyPeriod = TimePeriod.kMonth;
  int get timePeriodDays{
    return switch(historyPeriod) {
      TimePeriod.kWeek => 7,
      TimePeriod.kMonth => 30,
      TimePeriod.k3Months => 91,
      TimePeriod.k6Months => 182,
      TimePeriod.kYear => 365,
    };
  }

  DateTime get minDate => DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)
      .subtract(Duration(days: timePeriodDays));

  List<DailyRecordModel> _recordHistory = [];
  List<DailyRecordModel> get completeRecordHistory {
    return _recordHistory;
  }
  List<DailyRecordModel> get recordHistory {
    final timeThreshold = minDate;
    return _recordHistory
        .where((e) =>
        e.date.isAfter(timeThreshold))
        .toList();
  }
  List<(DateTime, DailyRecordModel)> get recordHistoryPair {
    final dateSteps = List<DateTime>.generate(
      timePeriodDays,
          (i) {
        return minDate.add(Duration(days: i + 1));
      },
    );

    List<(DateTime, DailyRecordModel)> rp = [];
    final records = recordHistory;
    for (final rh in records) {
      rp.add((rh.date.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0), rh));
    }
    if (rp.isEmpty) return [];

    DailyRecordModel.resetLerp();
    DailyRecordModel.lerpingList = rp;

    List<(DateTime, DailyRecordModel)> r = [];
    for (final date in dateSteps) {
      r.add((date, DailyRecordModel.getNextLerp(date, selectedPatient!)));
    }
    return r;
  }

  List<(String, double)> getBMIThresholds() {
    if (selectedPatient == null) return [];
    List<(String, double)> r = [];
    r.add(("Delgadez muy severa", 0.0)); // Severe thinness
    r.add(("Delgadez severa", 16.0 * selectedPatient!.height * selectedPatient!.height)); // Moderate thinness
    r.add(("Delgadez", 17.0 * selectedPatient!.height * selectedPatient!.height)); // Mild thinness
    r.add(("Normal", 18.5 * selectedPatient!.height * selectedPatient!.height)); // Normal
    r.add(("Sobrepeso", 25.0 * selectedPatient!.height * selectedPatient!.height)); // Overweight
    r.add(("Obesidad tipo 1", 30.0 * selectedPatient!.height * selectedPatient!.height)); // Obese Class1
    r.add(("Obesidad tipo 2", 35.0 * selectedPatient!.height * selectedPatient!.height)); // Obese Class2
    r.add(("Obesidad tipo 3", 40.0 * selectedPatient!.height * selectedPatient!.height)); // Obese Class3
    return r;
  }

  DailyRecordModel? getMinValues([DailyRecordModel? leftBorder]) {
    if (selectedPatient == null) return null;
    final history = recordHistory;
    if (history.isEmpty) return null;

    double? weight = leftBorder?.weight;
    double? waist = leftBorder?.waist;
    double? sysBP = leftBorder?.systolicBloodPressure;
    double? diaBP = leftBorder?.diastolicBloodPressure;
    double? sugarLevel = leftBorder?.sugarLevel;
    double? sleepTime = leftBorder?.sleepTime;
    for (final h in history) {
      weight = h.weight == null ? weight : math.min(h.weight!, weight?? 999999.0);
      waist = h.waist == null ? waist : math.min(h.waist!, waist?? 999999.0);
      sysBP = h.systolicBloodPressure == null ? sysBP : math.min(h.systolicBloodPressure!, sysBP?? 999999.0);
      diaBP = h.diastolicBloodPressure == null ? diaBP : math.min(h.diastolicBloodPressure!, diaBP?? 999999.0);
      sugarLevel = h.sugarLevel == null ? sugarLevel : math.min(h.sugarLevel!, sugarLevel?? 999999.0);
      sleepTime = h.sleepTime == null ? sleepTime : math.min(h.sleepTime!, sleepTime?? 999999.0);
    }
    return DailyRecordModel(
      -1, selectedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, EmotionalState.veryBad, sleepTime, false, false, false,
    );
  }
  DailyRecordModel? getMaxValues([DailyRecordModel? leftBorder]) {
    if (selectedPatient == null) return null;
    final history = recordHistory;
    if (history.isEmpty) return null;

    double? weight = leftBorder?.weight;
    double? waist = leftBorder?.waist;
    double? sysBP = leftBorder?.systolicBloodPressure;
    double? diaBP = leftBorder?.diastolicBloodPressure;
    double? sugarLevel = leftBorder?.sugarLevel;
    double? sleepTime = leftBorder?.sleepTime;
    for (final h in history) {
      weight = h.weight == null ? weight : math.max(h.weight!, weight?? 0.0);
      waist = h.waist == null ? waist : math.max(h.waist!, waist?? 0.0);
      sysBP = h.systolicBloodPressure == null ? sysBP : math.max(h.systolicBloodPressure!, sysBP?? 0.0);
      diaBP = h.diastolicBloodPressure == null ? diaBP : math.max(h.diastolicBloodPressure!, diaBP?? 0.0);
      sugarLevel = h.sugarLevel == null ? sugarLevel : math.max(h.sugarLevel!, sugarLevel?? 0.0);
      sleepTime = h.sleepTime == null ? sleepTime : math.max(h.sleepTime!, sleepTime?? 0.0);
    }
    return DailyRecordModel(
      -1, selectedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, EmotionalState.veryGood, sleepTime, true, true, true,
    );
  }
  DailyRecordModel? getFirstValues() {
    if (selectedPatient == null) return null;
    final history = recordHistory;
    if (history.isEmpty) return null;

    double? weight;
    double? waist;
    double? sysBP;
    double? diaBP;
    double? sugarLevel;
    double? sleepTime;
    EmotionalState? emotionalState;
    bool? medications;
    bool? weights;
    bool? cardio;
    for (final h in history) {
      weight ??= h.weight;
      waist ??= h.waist;
      sysBP ??= h.systolicBloodPressure;
      diaBP ??= h.diastolicBloodPressure;
      sugarLevel ??= h.sugarLevel;
      sleepTime ??= h.sleepTime;

      emotionalState??= h.emotionalState;
      medications??= h.medications;
      weights??= h.weights;
      cardio??= h.cardio;
    }
    return DailyRecordModel(
      -1, selectedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, emotionalState, sleepTime, medications, weights, cardio,
    );
  }
  DailyRecordModel? getLastValues() {
    if (selectedPatient == null) return null;
    final history = recordHistory;
    if (history.isEmpty) return null;

    double? weight;
    double? waist;
    double? sysBP;
    double? diaBP;
    double? sugarLevel;
    double? sleepTime;
    EmotionalState? emotionalState;
    bool? medications;
    bool? weights;
    bool? cardio;
    for (final h in history.reversed) {
      weight ??= h.weight;
      waist ??= h.waist;
      sysBP ??= h.systolicBloodPressure;
      diaBP ??= h.diastolicBloodPressure;
      sugarLevel ??= h.sugarLevel;
      sleepTime ??= h.sleepTime;

      emotionalState??= h.emotionalState;
      medications??= h.medications;
      weights??= h.weights;
      cardio??= h.cardio;
    }
    return DailyRecordModel(
      -1, selectedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, emotionalState, sleepTime, medications, weights, cardio,
    );
  }
  DailyRecordModel? getWeekAverageValues() {
    final realTimePeriod = historyPeriod;
    historyPeriod = TimePeriod.kWeek;
    final averageValues = getAverageValues();
    historyPeriod = realTimePeriod;
    return averageValues;
  }
  DailyRecordModel? getAverageValues() {
    if (selectedPatient == null) return null;
    final history = recordHistory;
    if (history.isEmpty) return null;

    double? weight;
    int weightCount = 0;
    double? waist;
    int waistCount = 0;
    double? sysBP;
    int sysBPCount = 0;
    double? diaBP;
    int diaBPCount = 0;
    double? sugarLevel;
    int sugarLevelCount = 0;
    double? sleepTime;
    int sleepTimeCount = 0;
    for (final h in history) {
      weight = h.weight == null ? weight : h.weight! + (weight?? 0.0);
      weightCount += h.weight == null ? 0 : 1;
      waist = h.waist == null ? waist : h.waist! + (waist?? 0.0);
      waistCount += h.waist == null ? 0 : 1;
      sysBP = h.systolicBloodPressure == null ? sysBP : h.systolicBloodPressure! + (sysBP?? 0.0);
      sysBPCount += h.systolicBloodPressure == null ? 0 : 1;
      diaBP = h.diastolicBloodPressure == null ? diaBP : h.diastolicBloodPressure! + (diaBP?? 0.0);
      diaBPCount += h.diastolicBloodPressure == null ? 0 : 1;
      sugarLevel = h.sugarLevel == null ? sugarLevel : h.sugarLevel! + (sugarLevel?? 0.0);
      sugarLevelCount += h.sugarLevel == null ? 0 : 1;
      sleepTime = h.sleepTime == null ? sleepTime : h.sleepTime! + (sleepTime?? 0.0);
      sleepTimeCount += h.sleepTime == null ? 0 : 1;
    }

    weight = weight == null ? null : ((weight / weightCount) * 100).round() / 100;
    waist = waist == null ? null : ((waist / waistCount) * 100).round() / 100;
    sysBP = sysBP == null ? null : ((sysBP / sysBPCount) * 100).round() / 100;
    diaBP = diaBP == null ? null : ((diaBP / diaBPCount) * 100).round() / 100;
    sugarLevel = sugarLevel == null ? null : ((sugarLevel / sugarLevelCount) * 100).round() / 100;
    sleepTime = sleepTime == null ? null : ((sleepTime / sleepTimeCount) * 100).round() / 100;

    return DailyRecordModel(
      -1, selectedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, EmotionalState.neutral, sleepTime, false, false, false,
    );
  }
  DailyRecordModel? getLeftBorderValues() {
    if (selectedPatient == null) return null;
    final timeThreshold = minDate;
    final history = _recordHistory
        .where((e) =>
        e.date.isBefore(timeThreshold))
        .toList();
    if (history.isEmpty) return null;

    double? weight;
    double? waist;
    double? sysBP;
    double? diaBP;
    double? sugarLevel;
    double? sleepTime;
    EmotionalState? emotionalState;
    bool? medications;
    bool? weights;
    bool? cardio;
    for (final h in history.reversed) {
      weight ??= h.weight;
      waist ??= h.waist;
      sysBP ??= h.systolicBloodPressure;
      diaBP ??= h.diastolicBloodPressure;
      sugarLevel ??= h.sugarLevel;
      sleepTime ??= h.sleepTime;

      emotionalState??= h.emotionalState;
      medications??= h.medications;
      weights??= h.weights;
      cardio??= h.cardio;
    }

    return DailyRecordModel(
      -1, selectedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, emotionalState, sleepTime, medications, weights, cardio,
    );
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


  @override
  void onInit() {
    basicValidator.addField(
      'weightGoal', label: "Meta de Peso",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'waistGoal', label: "Meta de Cintura",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'systolicGoal', label: "Meta Presión Sistólica",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'diastolicGoal', label: "Meta de Presión Diastólica",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'sugarGoal', label: "Meta de Azucar en Sangre",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    super.onInit();
  }


  void onPeriodChange(TimePeriod? newPeriod) {
    historyPeriod = newPeriod?? historyPeriod;
    update();
  }


  void onChangeMonth(int change) {
    calendarCurrentMonth += change;
    if (calendarCurrentMonth <= 0) {
      calendarCurrentYear -= 1;
      calendarCurrentMonth = 12;
    }
    else if (calendarCurrentMonth > 12) {
      calendarCurrentYear += 1;
      calendarCurrentMonth = 1;
    }
    update();
  }


  //Uint8List? pdfBytes;

  Future<void> updatePatientInfo([int? index]) async {
    patientIndex = index?? patientIndex;
    final patient = await manager.patients[AuthService.loggedUserNumber];
    if (patient == null) return;
    selectedPatient = patient[patientIndex];

    final subInfo = await manager.getPatientSubStatus(selectedPatient!.userNumber);
    if (subInfo == null) return;
    subscriptionStatus = subInfo.$1;
    subscriptionStarts = subInfo.$2;
    subscriptionEnds = subInfo.$3;

    _recordHistory = await manager.dailyRecords[AuthService.loggedUserNumber][selectedPatient!.userNumber]?? [];

    basicValidator.getController('weightGoal')!.text = selectedPatient?.weightGoal?.toString() ?? "";
    basicValidator.getController('waistGoal')!.text = selectedPatient?.waistGoal?.toString() ?? "";
    basicValidator.getController('systolicGoal')!.text = selectedPatient?.systolicPressureGoal?.toString() ?? "";
    basicValidator.getController('diastolicGoal')!.text = selectedPatient?.diastolicPressureGoal?.toString() ?? "";
    basicValidator.getController('sugarGoal')!.text = selectedPatient?.sugarGoal?.toString() ?? "";

    update();

    //_downloadPDFBytes();
  }

  /*void _downloadPDFBytes() {
    final pdfName = selectedPatient?.pdfName?? "";
    if (pdfName.isEmpty) return;

    final pdfURL = BlixDBManager.getUrl("uploads/pdf/$pdfName");

    http.get(Uri.parse(pdfURL)).then((response) {
      if (response.statusCode == 200) {
        pdfBytes = response.bodyBytes;
        update();
      }
    });
  }*/

  void goEditScreen() {
    Get.toNamed('/doctor/patient/edit/$patientIndex');
  }

  void loadPDFFile(String name, Uint8List data, String mime) {
    pdfFileName = name;
    pdfFileData = data;
    pdfFileMimeType = mime;
    Debug.log('PDF selected: $pdfFileName, ${data.length} bytes, mime: $pdfFileMimeType');
  }

  Future<String?> uploadPDFFile() async {
    if (selectedPatient == null) return "no user";

    if (pdfFileName == null || pdfFileData == null || pdfFileMimeType == null) {
      return "missing info";
    }

    if (selectedPatient!.pdfName.isNotEmpty) {
      final r = await manager.deleteFile(selectedPatient!.pdfName, "pdf/");
      if (r != null) {
        return "failed";
      }
    }

    final response = await manager.uploadFile(
      pdfFileName!, pdfFileData!, MediaType.parse(pdfFileMimeType!), "pdf/",
    );

    if (response.success) {
      if (await manager.changePatientPDFName(selectedPatient!.userNumber, response.name.replaceAll('"', ''))) {
        await manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber);
        await updatePatientInfo(patientIndex);
        Debug.log("uploadPDFFile update", overrideColor: Colors.green);
        update();
      }
      return null;
    }

    return response.name;
  }

  Future<String?> deletePDFFile() async {
    if (selectedPatient == null) return "no user";

    final response = await manager.deleteFile(selectedPatient!.pdfName, "pdf/");

    if (response == null) {
      if (await manager.changePatientPDFName(selectedPatient!.userNumber, "")) {
        await manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber);
        await updatePatientInfo(patientIndex);
        update();
      }
      return null;
    }

    return response;
  }

  /*void showModalWindow(
      BuildContext context, String title, Widget body,
      String closeText, Function() onClose) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: body,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onClose();
              },
              child: Text(closeText),
            ),
          ],
        );
      },
    );
  }*/

  void showPDFPreview(BuildContext context) {
    final pdfName = selectedPatient?.pdfName?? "";
    if (pdfName.isEmpty) return;

    final pdfURL = BlixDBManager.getUrl("uploads/pdf/$pdfName");
    launchUrl(Uri.parse(pdfURL));

    /*double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showModalWindow(
      context, "Expediente",
      SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: PdfPreview(
          //canChangeOrientation: false,
          //canChangePageFormat: false,
          //canDebug: false,
          //allowPrinting: false,
          //allowSharing: false,
          build: (_) => pdfBytes!,
        ),
      ),
      "Cerrar", ()  {},
    );*/
  }


  Future<String?> onUpdate() async {
    String? validationError;

    if (basicValidator.validateForm()) {
      var errors = await DBManager.instance!.updatePatientGoals(selectedPatient!.userNumber, basicValidator.getData());
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
    }
    else {
      validationError = "Hay errores en algunos datos";
    }

    return validationError;
  }
}