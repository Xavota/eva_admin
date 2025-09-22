import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:medicare/db_manager.dart';
import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:medicare/model/patient_list_model.dart';



bool datesAreSameDay(DateTime d1, DateTime d2) {
  return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
}

/// A simple holder for OkLab components.
class _OkLab {
  final double l, a, b;
  const _OkLab(this.l, this.a, this.b);
}

/// Cube‐root that handles negatives correctly.
double _cbrt(double x) => x >= 0
    ? math.pow(x, 1.0 / 3.0).toDouble()
    : -math.pow(-x, 1.0 / 3.0).toDouble();

/// Convert sRGB component (0–1) to linear light.
double _srgbToLinear(double c) {
  return (c <= 0.04045)
      ? c / 12.92
      : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

/// Convert linear‐light component (0–1) to sRGB.
double _linearToSrgb(double c) {
  return (c <= 0.0031308)
      ? 12.92 * c
      : 1.055 * math.pow(c, 1.0 / 2.4).toDouble() - 0.055;
}

/// Convert a Flutter [Color] (in sRGB) into OkLab space.
_OkLab _rgbToOkLab(Color color) {
  // 1) sRGB 0–255 → 0–1
  double r = color.r;
  double g = color.g;
  double b = color.b;

  // 2) sRGB → linear
  r = _srgbToLinear(r);
  g = _srgbToLinear(g);
  b = _srgbToLinear(b);

  // 3) linear RGB → LMS
  double l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
  double m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
  double s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

  // 4) LMS cube‐root
  double l_ = _cbrt(l);
  double m_ = _cbrt(m);
  double s_ = _cbrt(s);

  // 5) LMS → OkLab
  double L =  0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
  double A =  1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
  double B =  0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;

  return _OkLab(L, A, B);
}

/// Convert an OkLab triple back into a Flutter [Color].
Color _okLabToColor(_OkLab lab) {
  // 1) OkLab → LMS cube‐root domain
  double l_ = lab.l + 0.3963377774 * lab.a + 0.2158037573 * lab.b;
  double m_ = lab.l - 0.1055613458 * lab.a - 0.0638541728 * lab.b;
  double s_ = lab.l - 0.0894841775 * lab.a - 1.2914855480 * lab.b;

  // 2) invert cube‐root
  double l = l_ * l_ * l_;
  double m = m_ * m_ * m_;
  double s = s_ * s_ * s_;

  // 3) LMS → linear RGB
  double r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
  double g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
  double b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

  // 4) linear → sRGB
  r = _linearToSrgb(r);
  g = _linearToSrgb(g);
  b = _linearToSrgb(b);

  // 5) clamp and back to 0–255
  int ri = (r.clamp(0.0, 1.0) * 255).round();
  int gi = (g.clamp(0.0, 1.0) * 255).round();
  int bi = (b.clamp(0.0, 1.0) * 255).round();

  return Color.fromARGB(255, ri, gi, bi);
}

/// Linearly interpolate between [a] and [b] in OkLab space by t∈[0,1].
/// Alpha is lerped in sRGB space.
Color lerpOklab(Color a, Color b, double t) {
  // Convert endpoints into OkLab
  final lab1 = _rgbToOkLab(a);
  final lab2 = _rgbToOkLab(b);

  // Interpolate L, a, b
  final L = lab1.l + (lab2.l - lab1.l) * t;
  final A = lab1.a + (lab2.a - lab1.a) * t;
  final B = lab1.b + (lab2.b - lab1.b) * t;

  // Back to sRGB
  final rgb = _okLabToColor(_OkLab(L, A, B));

  // Interpolate alpha channel linearly
  final alpha = a.a + (b.a - a.a) * t;

  return rgb.withValues(alpha: alpha);
}

/// Interpolates a list of [colors] in OkLab space, so that:
///  - at t=0.0 -> colors[0],
///  - at t=1.0 -> colors.last,
///  - in between it walks through each segment evenly.
///
/// e.g. with 3 colors, segments=2:
///  t∈[0,0.5]  → lerp(colors[0], colors[1], t*2)
///  t∈[0.5,1]  → lerp(colors[1], colors[2], (t−0.5)*2)
Color multiLerpOklab(List<Color> colors, double t) {
  assert(colors.length >= 2, 'Need at least two colors to interpolate.');
  // Clamp t to [0,1]
  t = t.clamp(0.0, 1.0);

  final int n = colors.length;
  final int segments = n - 1;

  // Scale t up to [0, segments]
  final double scaledT = t * segments;
  // Which segment are we in?
  int idx = scaledT.floor();
  // Handle the edge‑case t==1.0
  if (idx >= segments) {
    return colors.last;
  }

  // Local t inside this segment
  final double localT = scaledT - idx;

  // Lerp between colors[idx] and colors[idx+1]
  return lerpOklab(colors[idx], colors[idx + 1], localT);
}


enum EmotionalState {
  veryGood,
  good,
  neutral,
  bad,
  veryBad;

  const EmotionalState();
}

extension EmotionalStateExtension on EmotionalState {
  String get name {
    switch (this) {
      case EmotionalState.veryGood:
        return 'Muy Bien';
      case EmotionalState.good:
        return 'Bien';
      case EmotionalState.neutral:
        return 'Neutral';
      case EmotionalState.bad:
        return 'Mal';
      case EmotionalState.veryBad:
        return 'Muy Mal';
    }
  }
  ImageProvider get emoji {
    switch (this) {
      case EmotionalState.veryGood:
        return AssetImage("");
      case EmotionalState.good:
        return AssetImage("");
      case EmotionalState.neutral:
        return AssetImage("");
      case EmotionalState.bad:
        return AssetImage("");
      case EmotionalState.veryBad:
        return AssetImage("");
    }
  }
}


class _LerpHelperValues {
  _LerpHelperValues();

  int? nextIndex;
  double? minValue;
  DateTime? minDate;
  double? maxValue;
  DateTime? maxDate;

  void reset() {
    nextIndex = null;
    minValue = null;
    minDate = null;
    maxValue = null;
    maxDate = null;
  }
}

class DailyRecordModel extends IdentifierModel {
  DailyRecordModel.empty(super.id, this.owner, this.date) : weight = null, waist = null,
      systolicBloodPressure = null, diastolicBloodPressure = null, sugarLevel = null,
      emotionalState = null, sleepTime = null, medications = null, exercise = null;
  DailyRecordModel(super.id, this.owner, this.date, this.weight, this.waist,
      this.systolicBloodPressure, this.diastolicBloodPressure, this.sugarLevel,
      this.emotionalState, this.sleepTime, this.medications, this.exercise);

  final PatientListModel owner;
  final DateTime date;
  final double? weight;
  final double? waist;
  final double? systolicBloodPressure;
  final double? diastolicBloodPressure;
  final double? sugarLevel;
  final EmotionalState? emotionalState;
  final double? sleepTime;
  final bool? medications;
  final bool? exercise;


  static Future<DailyRecordModel> fromJSON(Map<String, dynamic> json) async {
    JSONDecoder jsonDecoder = JSONDecoder(json);

    final ownerNumber = jsonDecoder.getString('patientNumber');
    final owner = (await DBManager.instance!.patients.getFromNumber(ownerNumber))!;
    DateTime date = jsonDecoder.getDateTime('date');
    double? weight = jsonDecoder.getDouble('weight');
    weight = weight == 0.0 ? null : weight;
    double? waist = jsonDecoder.getDouble('waist');
    waist = waist == 0.0 ? null : waist;
    double? systolicBloodPressure = jsonDecoder.getDouble('systolicBloodPressure');
    systolicBloodPressure = systolicBloodPressure == 0.0 ? null : systolicBloodPressure;
    double? diastolicBloodPressure = jsonDecoder.getDouble('diastolicBloodPressure');
    diastolicBloodPressure = diastolicBloodPressure == 0.0 ? null : diastolicBloodPressure;
    double? sugarLevel = jsonDecoder.getDouble('sugarLevel');
    sugarLevel = sugarLevel == 0.0 ? null : sugarLevel;
    int emotionalStateIndex = jsonDecoder.getInt('emotionalState', -1);
    EmotionalState? emotionalState = emotionalStateIndex == -1 ? null : EmotionalState.values[emotionalStateIndex];
    double? sleepTime = jsonDecoder.getDouble('sleepTime');
    sleepTime = sleepTime == 0.0 ? null : sleepTime;
    int? medicationsInt = jsonDecoder.getIntOrNull('medications');
    bool? medications = medicationsInt == null ? null : medicationsInt == 1;
    int? exerciseInt = jsonDecoder.getIntOrNull('exercise');
    bool? exercise = exerciseInt == null ? null : exerciseInt == 1;

    return DailyRecordModel(jsonDecoder.getId, owner, date, weight, waist,
        systolicBloodPressure, diastolicBloodPressure, sugarLevel,
        emotionalState, sleepTime, medications, exercise);
  }

  static Future<List<DailyRecordModel>> listFromJSON(List<dynamic> list) async {
    return await Future.wait(list.map((e) => DailyRecordModel.fromJSON(e)));
  }

  static List<DailyRecordModel>? _dummyList;

  static Future<List<DailyRecordModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = await listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/daly_record_list.json');
  }


  static List<(DateTime, DailyRecordModel)> lerpingList = [];


  static final _LerpHelperValues _lerpWeight = _LerpHelperValues();
  static final _LerpHelperValues _lerpWaist = _LerpHelperValues();
  static final _LerpHelperValues _lerpSysBP = _LerpHelperValues();
  static final _LerpHelperValues _lerpDiaBP = _LerpHelperValues();
  static final _LerpHelperValues _lerpSugarLevel = _LerpHelperValues();
  static final _LerpHelperValues _lerpSleepTime = _LerpHelperValues();

  static void resetLerp() {
    _lerpWeight.reset();
    _lerpWaist.reset();
    _lerpSysBP.reset();
    _lerpDiaBP.reset();
    _lerpSugarLevel.reset();
    _lerpSleepTime.reset();
  }


  static void _setUpperBound(int start, _LerpHelperValues object, double? Function(int) getValue) {
    for (int i = start; i < lerpingList.length; ++i) {
      final value = getValue(i);
      if (value != null) {
        object.nextIndex = i;
        object.maxValue = value;
        object.maxDate = lerpingList[i].$1;
        break;
      }
    }
  }

  static double _getNextLerp(DateTime newDate, _LerpHelperValues object, double? Function(int) getValue) {
    if (lerpingList.isEmpty) return 0.0;

    if (object.nextIndex == null) {
      object.nextIndex = lerpingList.length;
      _setUpperBound(0, object, getValue);
    }

    if (object.nextIndex! >= lerpingList.length) return object.maxValue?? 0.0;

    if (datesAreSameDay(lerpingList[object.nextIndex!].$1, newDate)) {
      object.minValue = object.maxValue;
      object.minDate = object.maxDate;

      final nextIndex = object.nextIndex! + 1;
      object.nextIndex = lerpingList.length;
      _setUpperBound(nextIndex, object, getValue);

      return object.minValue!;
    }

    if (object.minValue == null) return object.maxValue!;

    final rangeDateDifference = object.maxDate!.difference(object.minDate!).inDays;
    final minDateDifference = newDate.difference(object.minDate!).inDays;
    final alpha = minDateDifference / rangeDateDifference;

    return object.maxValue! * alpha + object.minValue! * (1.0 - alpha);
  }

  static DailyRecordModel getNextLerp(DateTime newDate, PatientListModel owner) {
    double? weight = _getNextLerp(newDate, _lerpWeight, (i) => lerpingList[i].$2.weight);
    double? waist = _getNextLerp(newDate, _lerpWaist, (i) => lerpingList[i].$2.waist);
    double? systolicBloodPressure = _getNextLerp(newDate, _lerpSysBP, (i) => lerpingList[i].$2.systolicBloodPressure);
    double? diastolicBloodPressure = _getNextLerp(newDate, _lerpDiaBP, (i) => lerpingList[i].$2.diastolicBloodPressure);
    double? sugarLevel = _getNextLerp(newDate, _lerpSugarLevel, (i) => lerpingList[i].$2.sugarLevel);
    EmotionalState? emotionalState =  null;
    double? sleepTime = _getNextLerp(newDate, _lerpSleepTime, (i) => lerpingList[i].$2.sleepTime);
    bool? medications = null;
    bool? exercise = null;

    return DailyRecordModel(-1, owner, newDate, weight, waist,
    systolicBloodPressure, diastolicBloodPressure, sugarLevel,
    emotionalState, sleepTime, medications, exercise);
  }
}
