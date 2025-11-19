import 'dart:math' as math;

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/daily_record_model.dart';

import 'package:medicare/db_manager.dart';


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


class PatientRecordHistoryController extends MyController {
  final manager = DBManager.instance!;

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

  PatientListModel? loggedPatient;
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
      r.add((date, DailyRecordModel.getNextLerp(date, loggedPatient!)));
    }
    return r;
  }

  List<(String, double)> getBMIThresholds() {
    if (loggedPatient == null) return [];
    List<(String, double)> r = [];
    r.add(("Delgadez muy severa", 0.0)); // Severe thinness
    r.add(("Delgadez severa", 16.0 * loggedPatient!.height * loggedPatient!.height)); // Moderate thinness
    r.add(("Delgadez", 17.0 * loggedPatient!.height * loggedPatient!.height)); // Mild thinness
    r.add(("Normal", 18.5 * loggedPatient!.height * loggedPatient!.height)); // Normal
    r.add(("Sobrepeso", 25.0 * loggedPatient!.height * loggedPatient!.height)); // Overweight
    r.add(("Obesidad tipo 1", 30.0 * loggedPatient!.height * loggedPatient!.height)); // Obese Class1
    r.add(("Obesidad tipo 2", 35.0 * loggedPatient!.height * loggedPatient!.height)); // Obese Class2
    r.add(("Obesidad tipo 3", 40.0 * loggedPatient!.height * loggedPatient!.height)); // Obese Class3
    return r;
  }

  DailyRecordModel getMinValues([DailyRecordModel? leftBorder]) {
    final history = recordHistory;
    if (history.isEmpty) return DailyRecordModel.empty(-1, loggedPatient!, DateTime.now());

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
      -1, loggedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, EmotionalState.veryBad, sleepTime, false, false, false,
    );
  }
  DailyRecordModel getMaxValues([DailyRecordModel? leftBorder]) {
    final history = recordHistory;
    if (history.isEmpty) return DailyRecordModel.empty(-1, loggedPatient!, DateTime.now());

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
      -1, loggedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, EmotionalState.veryGood, sleepTime, true, true, true,
    );
  }
  DailyRecordModel getFirstValues() {
    final history = recordHistory;
    if (history.isEmpty) return DailyRecordModel.empty(-1, loggedPatient!, DateTime.now());

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
      -1, loggedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, emotionalState, sleepTime, medications, weights, cardio,
    );
  }
  DailyRecordModel getLastValues() {
    final history = recordHistory;
    if (history.isEmpty) return DailyRecordModel.empty(-1, loggedPatient!, DateTime.now());

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
      -1, loggedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, emotionalState, sleepTime, medications, weights, cardio,
    );
  }
  DailyRecordModel getWeekAverageValues() {
    final realTimePeriod = historyPeriod;
    historyPeriod = TimePeriod.kWeek;
    final averageValues = getAverageValues();
    historyPeriod = realTimePeriod;
    return averageValues;
  }
  DailyRecordModel getAverageValues() {
    final history = recordHistory;
    if (history.isEmpty) return DailyRecordModel.empty(-1, loggedPatient!, DateTime.now());

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
      -1, loggedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, EmotionalState.neutral, sleepTime, false, false, false
    );
  }
  DailyRecordModel getLeftBorderValues() {
    final timeThreshold = minDate;
    final history = _recordHistory
        .where((e) =>
        e.date.isBefore(timeThreshold))
        .toList();
    if (history.isEmpty) return DailyRecordModel.empty(-1, loggedPatient!, DateTime.now());

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
      -1, loggedPatient!, history.first.date, weight, waist, sysBP, diaBP,
      sugarLevel, emotionalState, sleepTime, medications, weights, cardio,
    );
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


  Future<void> updateInfo() async {
    loggedPatient = AuthService.loggedUserData as PatientListModel;

    _recordHistory = await manager.dailyRecords[loggedPatient!.owner.userNumber][loggedPatient!.userNumber]?? [];

    update();
  }
}
