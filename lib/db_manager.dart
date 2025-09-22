import 'dart:typed_data';
import 'dart:convert' as cnv;
import 'dart:js_interop';
//import 'dart:js_util' as js_util;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:web/web.dart' as web;

import 'package:medicare/app_constant.dart';

import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/model/daily_record_model.dart';

import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/model/prescription_model.dart';
import 'package:medicare/model/secretary_model.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/date_model.dart';
import 'package:medicare/model/premium_parent_model.dart';
import 'package:medicare/model/premium_post_model.dart';
import 'package:medicare/model/premium_book_model.dart';
import 'package:medicare/model/premium_video_model.dart';

import 'package:blix_essentials/blix_essentials.dart';


/*@JS('Intl.DateTimeFormat().resolvedOptions().timeZone')
external String _timeZoneJS;

Future<String> getLocalTimezone() async {
  return _timeZoneJS;
}*/

/*Future<String> getLocalTimezone() async {
  try {
    // globalThis.Intl
    final intl = js_util.getProperty(js_util.globalThis, 'Intl');
    if (intl == null) return 'UTC';

    // new Intl.DateTimeFormat()
    final dtfCtor = js_util.getProperty(intl, 'DateTimeFormat');
    final dtf = js_util.callConstructor(dtfCtor, const []);

    // dtf.resolvedOptions()
    final opts = js_util.callMethod(dtf, 'resolvedOptions', const []);

    // opts.timeZone
    final tz = js_util.getProperty(opts, 'timeZone') as String?;
    return tz ?? 'UTC';
  } catch (_) {
    return 'UTC';
  }
}*/

@JS('Intl')
external JSObject _intl;

/// Create a new Intl.DateTimeFormat()
@JS('Intl.DateTimeFormat')
external JSObject _dateTimeFormat();

extension type DateTimeFormat(JSObject _) implements JSObject {
  external JSObject resolvedOptions();
}

extension type ResolvedOptions(JSObject _) implements JSObject {
  external String get timeZone;
}

Future<String> getLocalTimezoneWeb() async {
  try {
    final dtf = _dateTimeFormat() as DateTimeFormat;
    final opts = dtf.resolvedOptions() as ResolvedOptions;
    return opts.timeZone;
  } catch (_) {
    return 'UTC';
  }
}


class SecretariesMap {
  SecretariesMap();

  final Map<String, SecretaryModel> _secretaries = {};

  Future<SecretaryModel?> operator [](String index) async {
    if (_secretaries.containsKey(index)) {
      return _secretaries[index]!;
    }
    return await DBManager.instance!.getSecretary(doctorOwnerID: index);
  }

  void setSecretary(String index, SecretaryModel secretary) {
    _secretaries[index] = secretary;
  }
}

class PatientsMap {
  PatientsMap();

  final Map<String, List<PatientListModel>> _patients = {};

  Future<List<PatientListModel>?> operator [](String index) async {
    if (_patients.containsKey(index)) {
      return _patients[index]!;
    }
    return await DBManager.instance!.getPatients(doctorOwnerID: index);
  }

  void setPatientsList(String index, List<PatientListModel> list) {
    _patients[index] = list;
  }

  Future<PatientListModel?> getFromNumber(String patientNumber, {String? owner}) async {
    if (owner != null) {
      final pl = ((await this[owner])?? []);
      for (final p in pl) {
        if (p.userNumber == patientNumber) return p;
      }

      Debug.log("Patient not found by number, searching in db.", overrideColor: Colors.green);
      final patient = await DBManager.instance!.getPatients(userNumber: patientNumber);
      Debug.log("Patient found: $patient", overrideColor: Colors.green);
      return patient?.first;
    }

    for (final pl in _patients.values) {
      for (final p in pl) {
        if (p.userNumber == patientNumber) return p;
      }
    }

    Debug.log("Patient not found by number, searching in db.", overrideColor: Colors.green);
    final patient = await DBManager.instance!.getPatients(userNumber: patientNumber);
    Debug.log("Patient found: $patient", overrideColor: Colors.green);
    return patient?.first;
  }
}

class DatesMap {
  DatesMap();

  final Map<String, List<DateModel>> _dates = {};

  Future<List<DateModel>?> operator [](String index) async {
    if (_dates.containsKey(index)) {
      return _dates[index]!;
    }
    return await DBManager.instance!.getDates(doctorOwnerID: index);
  }

  void setDatesList(String index, List<DateModel> list) {
    _dates[index] = list;
  }
}

class PrescriptionsPatientsMap {
  PrescriptionsPatientsMap(this.doctorNumber, Map<String, List<PrescriptionModel>> prescriptions) : _prescriptions = prescriptions;

  final String doctorNumber;
  final Map<String, List<PrescriptionModel>> _prescriptions;
  Map<String, List<PrescriptionModel>> get p {
    return _prescriptions;
  }

  Future<List<PrescriptionModel>?> operator [](String index) async {
    if (_prescriptions.containsKey(index)) {
      return _prescriptions[index]!;
    }
    return await DBManager.instance!.getPatientPrescriptions(index, doctorNumber);
  }

  void setPrescriptionList(String index, List<PrescriptionModel> list) {
    _prescriptions[index] = list;
  }

  Future<PrescriptionModel?> getFromID(int id, [String? owner]) async {
    if (owner != null) {
      final pl = (await this[owner])?? [];
      for (final p in pl) {
        if (p.id == id) return p;
      }
      return null;
    }

    for (final pl in _prescriptions.values) {
      for (final p in pl) {
        if (p.id == id) return p;
      }
    }
    return null;
  }
}

class PrescriptionsDocsMap {
  PrescriptionsDocsMap();

  final Map<String, PrescriptionsPatientsMap> _prescriptions = {};
  Future<Map<String, List<PrescriptionModel>>?> p(String index) async {
    if (_prescriptions.containsKey(index)) {
      return _prescriptions[index]!.p;
    }
    await DBManager.instance!.getDoctorPrescriptions(index);
    return _prescriptions[index]?.p;
  }

  PrescriptionsPatientsMap operator [](String index) {
    if (!_prescriptions.containsKey(index)) {
      _prescriptions[index] = PrescriptionsPatientsMap(index, {});
    }
    return _prescriptions[index]!;
  }

  void setPrescriptionMap(String index, Map<String, List<PrescriptionModel>> list) {
    _prescriptions[index] = PrescriptionsPatientsMap(index, list);
  }
}

class DailyRecordsPatientsMap {
  DailyRecordsPatientsMap(this.doctorNumber, Map<String, List<DailyRecordModel>> records) : _records = records;

  final String doctorNumber;
  final Map<String, List<DailyRecordModel>> _records;
  Map<String, List<DailyRecordModel>> get p {
    return _records;
  }

  Future<List<DailyRecordModel>?> operator [](String index) async {
    if (_records.containsKey(index)) {
      return _records[index]!;
    }
    return await DBManager.instance!.getPatientDailyRecords(index, doctorOwnerID: doctorNumber);
  }

  void setRecordsList(String index, List<DailyRecordModel> list) {
    _records[index] = list;
  }

  Future<DailyRecordModel?> getFromID(int id, [String? owner]) async {
    if (owner != null) {
      final pl = (await this[owner])?? [];
      for (final p in pl) {
        if (p.id == id) return p;
      }
      return null;
    }

    for (final pl in _records.values) {
      for (final p in pl) {
        if (p.id == id) return p;
      }
    }
    return null;
  }
}

class DailyRecordsDocsMap {
  DailyRecordsDocsMap();

  final Map<String, DailyRecordsPatientsMap> _records = {};
  Future<Map<String, List<DailyRecordModel>>?> p(String index) async {
    if (_records.containsKey(index)) {
      return _records[index]!.p;
    }
    await DBManager.instance!.getDoctorDailyRecords(index);
    return _records[index]?.p;
  }

  DailyRecordsPatientsMap operator [](String index) {
    if (!_records.containsKey(index)) {
      _records[index] = DailyRecordsPatientsMap(index, {});
    }
    return _records[index]!;
  }

  void setRecordsMap(String index, Map<String, List<DailyRecordModel>> list) {
    _records[index] = DailyRecordsPatientsMap(index, list);
  }
}

enum PremiumContentTypes {
  kPosts,
  kBooks,
  kVideos,
}

class PremiumContentMap {
  PremiumContentMap(this.type, this.header, Map<String, List<PremiumParentModel>> content) : _content = content;

  final PremiumContentTypes type;
  final String header;
  final Map<String, List<PremiumParentModel>> _content;
  Map<String, List<PremiumParentModel>> get all {
    return _content;
  }
  List<PremiumParentModel> get allList {
    return _content.values.fold<List<PremiumParentModel>>(<PremiumParentModel>[], (f, e) => f..addAll(e)).toList();
  }

  Future<List<PremiumParentModel>?> operator [](String subHeaderName) async {
    if (_content.containsKey(subHeaderName)) {
      return _content[subHeaderName]!;
    }
    return await DBManager.instance!.getPremiumContentSubHeader(type, header, subHeaderName);
  }

  void setContentList(String subHeaderName, List<PremiumParentModel> list) {
    _content[subHeaderName] = list;
  }
  void removeContentList(String subHeaderName) {
    if (_content.containsKey(subHeaderName)) {
      _content.remove(subHeaderName);
    }
  }

  Future<PremiumParentModel?> getFromID(int id, [String? subHeaderName]) async {
    if (subHeaderName != null) {
      final pl = (await this[subHeaderName])?? [];
      for (final p in pl) {
        if (p.id == id) return p;
      }
      return null;
    }

    for (final pl in _content.values) {
      for (final p in pl) {
        if (p.id == id) return p;
      }
    }
    return null;
  }
}

class PremiumHeaderMap {
  PremiumHeaderMap(this.type, Map<String, PremiumContentMap> content) : _content = content;

  final PremiumContentTypes type;
  final Map<String, PremiumContentMap> _content;
  Future<Map<String, List<PremiumParentModel>>?> p(String headerName) async {
    if (_content.containsKey(headerName)) {
      return _content[headerName]!.all;
    }
    await DBManager.instance!.getPremiumContentHeader(type, headerName);
    return _content[headerName]?.all;
  }
  Map<String, Map<String, List<PremiumParentModel>>> get all {
    Map<String, Map<String, List<PremiumParentModel>>> r = {};
    for (final c in _content.entries) {
      r[c.key] = c.value.all;
    }
    return r;
  }
  List<PremiumParentModel> get allList {
    return _content.values.fold<List<PremiumParentModel>>(<PremiumParentModel>[], (f, e) => f..addAll(e.allList)).toList();
  }

  PremiumContentMap operator [](String headerName) {
    if (!_content.containsKey(headerName)) {
      _content[headerName] = PremiumContentMap(type, headerName, {});
    }
    return _content[headerName]!;
  }

  void setContentMap(String headerName, Map<String, List<PremiumParentModel>> list) {
    _content[headerName] = PremiumContentMap(type, headerName, list);
  }
}

class PremiumTypesMap {
  PremiumTypesMap();

  final Map<PremiumContentTypes, PremiumHeaderMap> _content = {};
  Future<Map<String, Map<String, List<PremiumParentModel>>>?> p(PremiumContentTypes type) async {
    if (_content.containsKey(type)) {
      return _content[type]!.all;
    }
    await DBManager.instance!.getPremiumContent();
    return _content[type]?.all;
  }
  Map<PremiumContentTypes, Map<String, Map<String, List<PremiumParentModel>>>> get all {
    Map<PremiumContentTypes, Map<String, Map<String, List<PremiumParentModel>>>> r = {};
    for (final c in _content.entries) {
      r[c.key] = c.value.all;
    }
    return r;
  }
  List<PremiumParentModel> get allList {
    return _content.values.fold<List<PremiumParentModel>>(<PremiumParentModel>[], (f, e) => f..addAll(e.allList)).toList();
  }

  PremiumHeaderMap operator [](PremiumContentTypes type) {
    if (!_content.containsKey(type)) {
      _content[type] = PremiumHeaderMap(type, {});
    }
    return _content[type]!;
  }

  void setContentMap(PremiumContentTypes type, Map<String, Map<String, List<PremiumParentModel>>> list) {
    _content[type] = PremiumHeaderMap(type, list.map<String, PremiumContentMap>((k, v) => MapEntry(k, PremiumContentMap(type, k, v))));
  }
}

enum SubscriptionStatus {
  kNotActive,
  kActive,
  kPending,
}

class CachedPremiumValue {
  const CachedPremiumValue({required this.status, required this.startTime,
    required this.endTime, required this.expireCache,});
  final SubscriptionStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime expireCache;
}

class CachedPremiumStatus {
  final Map<String, CachedPremiumValue> _cachedValues = {};

  Future<CachedPremiumValue?> _getStatusAsync(String userNumber) async {
    final status = await DBManager.instance!.getPatientSubStatus(userNumber);
    if (status == null) return null;
    _cachedValues[userNumber] = CachedPremiumValue(
      status: status.$1,
      startTime: status.$2,
      endTime: status.$3,
      expireCache: DateTime.now().add(Duration(minutes: 2)),
    );
    return _cachedValues[userNumber]!;
  }

  dynamic operator [](String userNumber) {
    if (_cachedValues.containsKey(userNumber)) {
      Debug.log("User status is cached", overrideColor: Colors.amber);
      if (_cachedValues[userNumber]!.expireCache.isBefore(DateTime.now())) {
        Debug.log("Cached expired", overrideColor: Colors.amber);
      }
    }
    if (!_cachedValues.containsKey(userNumber) ||
        _cachedValues[userNumber]!.expireCache.isBefore(DateTime.now())) {
      return _getStatusAsync(userNumber);
    }
    return _cachedValues[userNumber]!;
  }

}

class DBManager {
  static DBManager? _instance;

  static DBManager? get instance{
    return _instance ??= DBManager();
  }

  List<DoctorModel>? _doctors;
  Future<List<DoctorModel>?> get doctors async {
    if (_doctors != null) {
      return _doctors!;
    }
    return (await getDoctors())!;
  }
  final SecretariesMap _secretaries = SecretariesMap();
  SecretariesMap get secretaries {
    return _secretaries;
  }
  final PatientsMap _patients = PatientsMap();
  PatientsMap get patients {
    return _patients;
  }
  final DatesMap _dates = DatesMap();
  DatesMap get dates {
    return _dates;
  }
  final PrescriptionsDocsMap _prescription = PrescriptionsDocsMap();
  PrescriptionsDocsMap get prescription {
    return _prescription;
  }
  final DailyRecordsDocsMap _dailyRecords = DailyRecordsDocsMap();
  DailyRecordsDocsMap get dailyRecords {
    return _dailyRecords;
  }
  final PremiumTypesMap _premiumContent = PremiumTypesMap();
  PremiumTypesMap get premiumContent {
    return _premiumContent;
  }

  final CachedPremiumStatus _patientsPremiumStatus = CachedPremiumStatus();
  CachedPremiumStatus get patientsPremiumStatus {
    return _patientsPremiumStatus;
  }

  static final int maxDoctorID = 1000;

  String getUploadUrl(String imageUrl) {
    return "${BlixDBManager.baseUrl}uploads/$imageUrl";
  }

  void preloadImage(String imageUrl) {
    if (imageUrl.isEmpty) return;

    CachedNetworkImageProvider(getUploadUrl(imageUrl))
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) { /*Debug.log("Image loaded in ${synchronousCall ? "synchronous" : "asynchronous"} call");*/ }));
  }


  Future<bool?>
  validatePasswordAdmin(String email, String password) async {
    final response = await BlixDBManager.httpPost(
      "check_password_admin.php",
      params: {
        "email": email,//"test@mail.com",
        "password": password,//"Blix1234",
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }

    return response.response == "1";
  }

  Future<String?>
  validatePasswordUser(String userNumber, String pin) async {
    final response = await BlixDBManager.httpPost(
      "check_password_user.php",
      params: {
        "userNumber": userNumber,//"test@mail.com",
        "pin": pin,//"T3s7P4S5w0rd",
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      for (final e in response.errors) {
        if (e == "archived") {
          return e;
        }
      }
      return null;
    }

    return response.response.replaceAll('"', '');
  }


  Future<String?>
  getLastDoctorID() async {
    final response = await BlixDBManager.httpPost(
      "fetch_last_doctor_id.php",
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    String idStr = response.response.replaceAll('"', '');
    int? id = int.tryParse(idStr);
    if (id != null && id > maxDoctorID) {
      id = maxDoctorID;
      idStr = MyStringUtils.addZerosAtFront(id, lengthRequired: 4);
    }
    return idStr;
  }

  Future<Map<String, String>?>
  registerDoctor(Map<String, dynamic> data) async {
    final response = await BlixDBManager.httpPost(
      "register_doctor.php",
      params: {
        "userNumber": data["userNumber"],
        "pin": data["pin"],
        "proNumber": data["professionalNumber"],
        "fullName": data["fullName"],
        "speciality": data["speciality"],
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "Duplicated number") {
          r.addAll({"userNumber": "Número de usuario duplicado"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  updateDoctor(Map<String, dynamic> data) async {
    final response = await BlixDBManager.httpPost(
      "update_doctor.php",
      params: {
        "userNumber": data["userNumber"],
        "pin": data["pin"],
        "fullName": data["fullName"],
        "proNumber": data["professionalNumber"],
        "speciality": data["speciality"],
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "No user") {
          r.addAll({"userNumber": "Número de usuario inexistente"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<List<DoctorModel>?>
  getDoctors({String userNumber = ""}) async {
    final response = await BlixDBManager.httpPost(
      "fetch_doctors.php",
      params: {
        "number": userNumber,
      }
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final newList = DoctorModel.listFromJSON(cnv.jsonDecode(response.response) as List);
    if (userNumber.isEmpty) {
      _doctors = newList;
    }
    return newList;
  }

  Future<bool> changeDoctorStatus(String userNumber, bool newStatus) async {
    final response = await BlixDBManager.httpPost(
      "change_doctor_status.php",
      params: {
        "number": userNumber,
        "newStatus": newStatus ? "1" : "0",
      },
      //debug: true,
    );
    return response.errors.isEmpty;
  }


  String getSecretaryID(String ownerID) {
    return "S$ownerID";
  }

  Future<bool?> isSecretaryRegistered(String ownerID) async {
    final response = await BlixDBManager.httpPost(
      "exists_secretary.php",
      params: {
        "owner": ownerID,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    return response.response == "1";
  }

  Future<Map<String, String>?>
  registerSecretary(Map<String, dynamic> data, String ownerID) async {
    final response = await BlixDBManager.httpPost(
      "register_secretary.php",
      params: {
        "owner": ownerID,
        "userNumber": data["userNumber"],
        "pin": data["pin"],
        "fullName": data["fullName"],
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "Duplicated number") {
          r.addAll({"userNumber": "Número de usuario duplicado"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  updateSecretary(Map<String, dynamic> data) async {
    final response = await BlixDBManager.httpPost(
      "update_secretary.php",
      params: {
        "userNumber": data["userNumber"],
        "pin": data["pin"],
        "fullName": data["fullName"],
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "No user") {
          r.addAll({"userNumber": "Número de usuario inexistente"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<SecretaryModel?>
  getSecretary({String doctorOwnerID = "", String userNumber = ""}) async {
    final response = await BlixDBManager.httpPost(
      "fetch_secretary.php",
      params: {
        "number": userNumber,
        "owner": doctorOwnerID,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final newSecretary = SecretaryModel.fromJSON(cnv.jsonDecode(response.response));
    if (userNumber.isEmpty && doctorOwnerID.isNotEmpty) {
      _secretaries.setSecretary(doctorOwnerID, newSecretary);
    }
    return newSecretary;
  }


  Future<(SubscriptionStatus, DateTime?, DateTime?)?> getPatientSubStatus(String userNumber) async {
    final response = await BlixDBManager.httpPost(
      "check_suscription_status_patient.php",
      params: {
        "number": userNumber
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final responseJson = cnv.jsonDecode(response.response);

    final status = SubscriptionStatus.values[responseJson["status"]];
    final starts = status != SubscriptionStatus.kNotActive ? DateTime.tryParse(responseJson["starts"]) : null;
    final ends = status != SubscriptionStatus.kNotActive ? DateTime.tryParse(responseJson["ends"]) : null;
    return (status, starts, ends);
  }

  Future<Map<String, String>?> activatePatientSub(String userNumber, DateTime start, DateTime end) async {
    final response = await BlixDBManager.httpPost(
      "activate_suscription_patient.php",
      params: {
        "number": userNumber,
        "timeToStart": dbDateTimeFormatter.format(start),
        "timeToEnd": dbDateTimeFormatter.format(end),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "No user") {
          r.addAll({"server": "Usuario inexistente"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<String?> cancelPatientSub(String userNumber) async {
    final response = await BlixDBManager.httpPost(
      "cancel_suscription_patient.php",
      params: {
        "number": userNumber,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      for (final e in response.errors) {
        if (e == "Missing info") {
          return "Información faltante";
        }
        else if (e == "No user") {
          return "Usuario inexistente";
        }
        else {
         return "Hubo un error en el servidor. Intentalo de nuevo más tarde";
        }
      }
    }

    return null;
  }


  Future<String?> getLastPatientID() async {
    final response = await BlixDBManager.httpPost(
      "fetch_last_patient_id.php",
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    String idStr = response.response.replaceAll('"', '');
    int? id = int.tryParse(idStr);
    if (id != null && id <= maxDoctorID) {
      id = maxDoctorID + 1;
      idStr = MyStringUtils.addZerosAtFront(id, lengthRequired: 4);
    }
    return idStr;
  }

  Future<Map<String, String>?>
  registerPatient(Map<String, dynamic> data, String ownerID) async {
    final response = await BlixDBManager.httpPost(
      "register_patient.php",
      params: {
        "owner": ownerID,
        "userNumber": data["userNumber"],
        "pin": data["pin"],
        "fullName": data["fullName"],
        "age": data["age"],
        "weight": data["weight"],
        "sex": data["sex"].index.toString(),
        "height": data["height"],
        "waist": data["waist"],
        "job": data["job"],
        "birthDate": dbDateFormatter.format(DateTime.parse(data["birthDate"])),
        "phoneNumber": data["phoneNumber"],
        "consultReasons": (data["consultation"] as List<ConsultationReason>).map<int>((e) => e.dbid).toList().join(","),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "Duplicated number") {
          r.addAll({"userNumber": "Número de usuario duplicado"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  updatePatient(Map<String, dynamic> data) async {
    final response = await BlixDBManager.httpPost(
      "update_patient.php",
      params: {
        "userNumber": data["userNumber"],
        "pin": data["pin"],
        "fullName": data["fullName"],
        "age": data["age"],
        "weight": data["weight"],
        "sex": data["sex"].index.toString(),
        "height": data["height"],
        "waist": data["waist"],
        "job": data["job"],
        "birthDate": dbDateFormatter.format(DateTime.parse(data["birthDate"])),
        "phoneNumber": data["phoneNumber"],
        "consultReasons": (data["consultation"] as List<ConsultationReason>).map<int>((e) => e.dbid).toList().join(","),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "No user") {
          r.addAll({"userNumber": "Número de usuario inexistente"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  updatePatientGoals(String userNumber, Map<String, dynamic> data) async {
    final response = await BlixDBManager.httpPost(
      "update_patient_goals.php",
      params: {
        "userNumber": userNumber,
        "weightGoal": (data["weightGoal"]?? "") == "" ? "0.0" : data["weightGoal"],
        "waistGoal": (data["waistGoal"]?? "") == "" ? "0.0" : data["waistGoal"],
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "No user") {
          r.addAll({"userNumber": "Número de usuario inexistente"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<List<PatientListModel>?>
  getPatients({String doctorOwnerID = "", String userNumber = ""}) async {
    //Debug.log("getPatients", overrideColor: Colors.greenAccent);
    final response = await BlixDBManager.httpPost(
      "fetch_patients.php",
      params: {
        "number": userNumber,
        "owner": doctorOwnerID,
      }
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final newList = await PatientListModel.listFromJSON(cnv.jsonDecode(response.response) as List);
    if (userNumber.isEmpty && doctorOwnerID.isNotEmpty) {
      _patients.setPatientsList(doctorOwnerID, newList);
    }
    return newList;
  }

  Future<bool> changePatientStatus(String userNumber, bool newStatus) async {
    final response = await BlixDBManager.httpPost(
      "change_patient_status.php",
      params: {
        "number": userNumber,
        "newStatus": newStatus ? "1" : "0",
      },
      //debug: true,
    );
    return response.errors.isEmpty;
  }

  Future<bool> changePatientPDFName(String userNumber, String pdfName) async {
    final response = await BlixDBManager.httpPost(
      "change_patient_pdf_name.php",
      params: {
        "number": userNumber,
        "pdfName": pdfName,
      },
      //debug: true,
    );
    return response.errors.isEmpty;
  }


  Future<Map<String, String>?>
  registerDate(Map<String, dynamic> data, String ownerID) async {
    //final localTimeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    final localTimeZoneName = await getLocalTimezoneWeb();

    final consultReasons = (data["tempConsultReasons"] as List<ConsultationReason>?);
    final response = await BlixDBManager.httpPost(
      "register_date.php",
      params: {
        "owner": ownerID,
        "date": dbDateTimeFormatter.format(DateTime.parse(data["date"])),
        "timeZone": localTimeZoneName,
        "phoneNumber": data["phoneNumber"]?? "",

        "userNumber": data["userNumber"]?? "",
        "tempFullName": data["tempFullName"]?? "",
        "tempPhoneNumber": data["phoneNumber"]?? "",
        "tempConsultReasons": consultReasons?.map<int>((e) => e.dbid).toList().join(",")?? "",
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "No user") {
          r.addAll({"userNumber": "Número de usuario inexistente"});
        }
        else if (e == "No owner") {
          r.addAll({"server": "Número de doctor inexistente"});
        }
        else if (e == "Date") {
          r.addAll({"date": "Fecha muy cercana a otra cita del usuario"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<List<DateModel>?>
  getDates({String doctorOwnerID = "", String userNumber = ""}) async {
    /*final localTimeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    Debug.log("localTimeZoneName: $localTimeZoneName");*/
    final localTimeZoneName = await getLocalTimezoneWeb();
    //Debug.log("localTimeZoneName: $localTimeZoneName2");

    final response = await BlixDBManager.httpPost(
      "fetch_dates.php",
      params: {
        "owner": doctorOwnerID,
        "timeZone": localTimeZoneName,
        "userNumber": userNumber,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final newList = await DateModel.listFromJSON(cnv.jsonDecode(response.response) as List);
    if (userNumber.isEmpty && doctorOwnerID.isNotEmpty) {
      _dates.setDatesList(doctorOwnerID, newList);
    }
    return newList;
  }


  Future<Map<String, String>?>
  registerPrescription(Map<String, dynamic> data, String ownerID) async {
    final response = await BlixDBManager.httpPost(
      "register_prescription.php",
      params: {
        "patientNumber": ownerID,
        "creationDate": dbDateFormatter.format(DateTime.now()),
        "plainText": data["plainText"]?.trim()?? "",
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, List<PrescriptionModel>>?>
  getDoctorPrescriptions(String doctorOwnerID) async {
    final response = await BlixDBManager.httpPost(
      "fetch_prescriptions.php",
      params: {
        "owner": doctorOwnerID,
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final jsonResponse = cnv.jsonDecode(response.response) as Map<String, dynamic>;
    Map<String, List<PrescriptionModel>> r = {};
    for (final p in jsonResponse.entries) {
      final newList = await PrescriptionModel.listFromJSON(p.value);
      r[p.key] = newList;
    }
    _prescription.setPrescriptionMap(doctorOwnerID, r);
    return r;
  }

  Future<List<PrescriptionModel>?>
  getPatientPrescriptions(String userNumber, [String? doctorOwnerID]) async {
    final response = await BlixDBManager.httpPost(
      "fetch_prescriptions.php",
      params: {
        "userNumber": userNumber,
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final jsonList = cnv.jsonDecode(response.response) as List;
    if (jsonList.isEmpty) return [];

    final newList = await PrescriptionModel.listFromJSON(jsonList);
    final docID = doctorOwnerID?? (jsonList[0]["owner"] as String?)?? "";

    _prescription[docID].setPrescriptionList(userNumber, newList);
    return newList;
  }

  Future<Map<String, String>?>
  editPrescription(Map<String, dynamic> data, int id) async {
    final response = await BlixDBManager.httpPost(
      "update_prescription.php",
      params: {
        "id": id.toString(),
        "plainText": data["plainText"]?.trim()?? "",
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  deletePrescription(int id) async {
    final response = await BlixDBManager.httpPost(
      "delete_prescription.php",
      params: {
        "id": id.toString(),
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }


  Future<Map<String, String>?>
  saveDailyRecord(Map<String, dynamic> data, String userNumber) async {
    final response = await BlixDBManager.httpPost(
      "save_daily_record.php",
      params: {
        "patientNumber": userNumber,
        "date": dbDateFormatter.format(DateTime.now()),
        "weight": data["weight"]?? "",
        "waist": data["waist"]?? "",
        "systolicBloodPressure": data["systolicBloodPressure"]?? "",
        "diastolicBloodPressure": data["diastolicBloodPressure"]?? "",
        "sugarLevel": data["sugarLevel"]?? "",
        "emotionalState": data["emotionalState"] == null ? "" : data["emotionalState"].index.toString(),
        "sleepTime": data["sleepTime"]?? "",
        "medications": data["medications"] == null ? "" : (data["medications"] ? "1" : "0"),
        "exercise": data["exercise"] == null ? "" : (data["exercise"] ? "1" : "0"),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, List<DailyRecordModel>>?>
  getDoctorDailyRecords(String doctorOwnerID, [bool ofToday = false]) async {
    final response = await BlixDBManager.httpPost(
      "fetch_daily_records.php",
      params: {
        "owner": doctorOwnerID,
        if (ofToday) "date": dbDateFormatter.format(DateTime.now()),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final jsonResponse = cnv.jsonDecode(response.response) as Map<String, dynamic>;
    Map<String, List<DailyRecordModel>> r = {};
    for (final p in jsonResponse.entries) {
      final newList = await DailyRecordModel.listFromJSON(p.value);
      r[p.key] = newList;
    }
    if (!ofToday) {
      _dailyRecords.setRecordsMap(doctorOwnerID, r);
    }
    return r;
  }

  Future<List<DailyRecordModel>?>
  getPatientDailyRecords(String userNumber, {String? doctorOwnerID, bool ofToday = false}) async {
    final response = await BlixDBManager.httpPost(
      "fetch_daily_records.php",
      params: {
        "userNumber": userNumber,
        if (ofToday) "date": dbDateFormatter.format(DateTime.now()),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final jsonList = cnv.jsonDecode(response.response) as List;
    if (jsonList.isEmpty) return [];

    final newList = await DailyRecordModel.listFromJSON(jsonList);
    final docID = doctorOwnerID?? (jsonList[0]["owner"] as String?)?? "";

    if (!ofToday) {
      _dailyRecords[docID].setRecordsList(userNumber, newList);
    }
    return newList;
  }


  Future<Map<String, String>?>
  registerPremiumContentHeader(PremiumContentTypes type, String name, String? parent) async {
    final response = await BlixDBManager.httpPost(
      "register_premium_content_header.php",
      params: {
        "type": type.index.toString(),
        "name": name,
        "parent": parent?? "",
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "Parent") {
          r.addAll({"server": "La categoría padre no existe"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  void _preloadPremiumContentImages() {
    final images = _premiumContent.allList
        .fold<List<(PremiumContentTypes, List<String>)>>([], (s, e) => s..add(
        switch (e) {
          PremiumPostModel(:var id, :var tile, :var description, :var images) => (PremiumContentTypes.kPosts, images),
          PremiumBookModel(:var id, :var tile, :var frontPage, :var book) => (PremiumContentTypes.kBooks, [frontPage]),
          PremiumVideoModel(:var id, :var tile, :var description, :var images) => (PremiumContentTypes.kVideos, []),
          PremiumParentModel() => throw UnimplementedError(),
        }
    ));
    for (final imgP in images) {
      final prefix = switch(imgP.$1) {
        PremiumContentTypes.kPosts => "images/premium_posts/",
        PremiumContentTypes.kBooks => "images/premium_books/",
        PremiumContentTypes.kVideos => "images/premium_videos/",
      };
      for (final img in imgP.$2) {
        preloadImage("$prefix$img");
      }
    }
  }

  Future<Map<PremiumContentTypes, Map<String, Map<String, List<PremiumParentModel>>>>?>
  getPremiumContent() async {
    final response = await BlixDBManager.httpPost(
      "fetch_premium_content.php",
      params: {},
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final jsonResponse = cnv.jsonDecode(response.response) as Map<String, dynamic>;
    Map<PremiumContentTypes, Map<String, Map<String, List<PremiumParentModel>>>> r = {};
    for (final t in jsonResponse.entries) {
      final type = PremiumContentTypes.values[int.parse(t.key.replaceAll('t', ''))];
      r[type] = {};
      if (t.value is Map<String, dynamic>) {
        for (final h in t.value.entries) {
          r[type]![h.key] = {};
          if (h.value is Map<String, dynamic>) {
            for (final s in h.value.entries) {
              final newList = switch(type) {
                PremiumContentTypes.kPosts => PremiumPostModel.listFromJSON(s.value),
                PremiumContentTypes.kBooks => PremiumBookModel.listFromJSON(s.value),
                PremiumContentTypes.kVideos => PremiumVideoModel.listFromJSON(s.value),
              };

              r[type]![h.key]![s.key] = newList;
            }
          }
        }
      }

      _premiumContent.setContentMap(type, r[type]!);
    }
    _preloadPremiumContentImages();
    return r;
  }

  Future<Map<String, List<PremiumParentModel>>?>
  getPremiumContentHeader(PremiumContentTypes type, String header) async {
    final response = await BlixDBManager.httpPost(
      "fetch_premium_content.php",
      params: {
        "type": type.index.toString(),
        "header": header,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final jsonResponse = cnv.jsonDecode(response.response) as Map<String, dynamic>;
    Map<String, List<PremiumParentModel>> r = {};
    for (final p in jsonResponse.entries) {
      p.value as Map<String, dynamic>;
      final newList = switch(type) {
        PremiumContentTypes.kPosts => PremiumPostModel.listFromJSON(p.value),
        PremiumContentTypes.kBooks => PremiumBookModel.listFromJSON(p.value),
        PremiumContentTypes.kVideos => PremiumVideoModel.listFromJSON(p.value),
      };
      r[p.key] = newList;
    }
    _premiumContent[type].setContentMap(header, r);
    _preloadPremiumContentImages();
    return r;
  }

  Future<List<PremiumParentModel>?>
  getPremiumContentSubHeader(PremiumContentTypes type, String header, String subHeader) async {
    final response = await BlixDBManager.httpPost(
      "fetch_premium_content.php",
      params: {
        "type": type.index.toString(),
        "header": header,
        "subHeader": subHeader,
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    final jsonResponse = cnv.jsonDecode(response.response);
    if (jsonResponse is! List<dynamic>) {
      //_premiumContent[header].setContentList(subHeader, []);
      _premiumContent[type][header].removeContentList(subHeader);
      return null;
    }
    List<PremiumParentModel> r = switch(type) {
      PremiumContentTypes.kPosts => PremiumPostModel.listFromJSON(jsonResponse),
      PremiumContentTypes.kBooks => PremiumBookModel.listFromJSON(jsonResponse),
      PremiumContentTypes.kVideos => PremiumVideoModel.listFromJSON(jsonResponse),
    };
    _premiumContent[type][header].setContentList(subHeader, r);
    _preloadPremiumContentImages();
    return r;
  }

  Future<Map<String, String>?>
  editPremiumContentHeader(String name, String prevName) async {
    final response = await BlixDBManager.httpPost(
      "update_premium_content_header.php",
      params: {
        "name": name,
        "prevName": prevName,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  deletePremiumContentHeader(String name, [String? parent]) async {
    final response = await BlixDBManager.httpPost(
      "delete_premium_content_header.php",
      params: {
        "name": name,
        if (parent != null) "parent": parent,
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "Parent") {
          r.addAll({"server": "La categoría no existe"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    final jsonResponse = cnv.jsonDecode(response.response) as Map<String, dynamic>;
    for (final fileName in jsonResponse.entries) {
      if (fileName.key == "image") {
        await deleteFile(fileName.value as String, "images/premium_posts/");
      }
      else if (fileName.key == "frontPage") {
        await deleteFile(fileName.value as String, "images/premium_books/");
      }
      else if (fileName.key == "pdf") {
        await deleteFile(fileName.value as String, "pdf/premium_books/");
      }
      else if (fileName.key == "video") {
        await deleteFile(fileName.value as String, "videos/premium_videos/");
      }
    }

    return null;
  }


  Future<({int? id, Map<String, String>? errors})>
  registerPremiumPost(Map<String, dynamic> data, String header, String subHeader) async {
    final response = await BlixDBManager.httpPost(
      "register_premium_post.php",
      params: {
        "header": header,
        "subHeader": subHeader,
        "title": data["title"]?? "",
        "description": data["description"]?? "",
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "Parent") {
          r.addAll({"server": "La categoría padre no existe"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return (id: null, errors: r);
    }

    return (id: int.tryParse(response.response), errors: null);
  }

  Future<Map<String, String>?>
  registerPremiumPostImage(String imageName, int parent) async {
    final response = await BlixDBManager.httpPost(
      "register_premium_post_image.php",
      params: {
        "name": imageName,
        "postID": parent.toString(),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  editPremiumPost(Map<String, dynamic> data, int id) async {
    final response = await BlixDBManager.httpPost(
      "update_premium_post.php",
      params: {
        "id": id.toString(),
        "title": data["title"]?? "",
        "description": data["description"]?? "",
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  deletePremiumPost(int id) async {
    final response = await BlixDBManager.httpPost(
      "delete_premium_post.php",
      params: {
        "id": id.toString(),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    final jsonResponse = cnv.jsonDecode(response.response) as List<dynamic>;
    for (final String imgName in jsonResponse) {
      await deleteFile(imgName, "images/premium_posts/");
    }

    return null;
  }

  Future<Map<String, String>?>
  deletePremiumPostImage(String imageName) async {
    final response = await BlixDBManager.httpPost(
      "delete_premium_post_image.php",
      params: {
        "name": imageName,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    await deleteFile(imageName, "images/premium_posts/");

    return null;
  }


  Future<Map<String, String>?>
  registerPremiumBook(Map<String, dynamic> data, String header, String subHeader, String frontPageName, String bookName) async {
    final response = await BlixDBManager.httpPost(
      "register_premium_book.php",
      params: {
        "header": header,
        "subHeader": subHeader,
        "title": data["title"]?? "",
        "frontPageName": frontPageName,
        "bookName": bookName,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "Parent") {
          r.addAll({"server": "La categoría padre no existe"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  editPremiumBook(Map<String, dynamic> data, int id, String frontPageName, String bookName) async {
    final response = await BlixDBManager.httpPost(
      "update_premium_book.php",
      params: {
        "id": id.toString(),
        "title": data["title"]?? "",
        "frontPageName": frontPageName,
        "bookName": bookName,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    return null;
  }

  Future<Map<String, String>?>
  deletePremiumBook(int id) async {
    final response = await BlixDBManager.httpPost(
      "delete_premium_book.php",
      params: {
        "id": id.toString(),
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else {
          r.addAll({"server": "Hubo un error en el servidor."
              " Intentalo de nuevo más tarde"});
        }
      }
      return r;
    }

    final jsonResponse = cnv.jsonDecode(response.response) as Map<String, dynamic>;
    await deleteFile(jsonResponse['frontPage'], "images/premium_books/");
    await deleteFile(jsonResponse['book'], "pdf/premium_books/");

    return null;
  }


  // Base URL: ./uploads/
  Future<({bool success, String name})> uploadFile(String name, Uint8List fileData, parser.MediaType type, String pathToUpload) async {
    List<http.MultipartFile> files = [
      http.MultipartFile.fromBytes(
        'file',
        List<int>.from(fileData),
        contentType: type,
        filename: name,
      ),
    ];

    final response = await BlixDBManager.httpMultipartRequest(
      "upload_file.php", files: files,
      params: {
        "dir": pathToUpload,
        "type": "${type.type}/${type.subtype}",
      },
      //debug: true,
    );

    if (response.errors.isNotEmpty) {
      return (success: false, name: response.errors[0]);
    }

    return (success: true, name: response.response);
  }

  // Base URL: ./uploads/
  Future<String?> deleteFile(String name, String path) async {
    final response = await BlixDBManager.httpPost(
      "delete_file.php",
      params: {
        "path": path,
        "name": name,
      },
      //debug: true,
    );
    if (response.errors.isNotEmpty) {
      return response.errors[0];
    }
    return null;
  }
}