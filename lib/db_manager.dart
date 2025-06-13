import 'dart:typed_data';
import 'dart:convert' as cnv;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:medicare/app_constant.dart';

import 'package:medicare/helpers/utils/my_string_utils.dart';

import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/model/secretary_model.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/date_model.dart';

import 'package:blix_essentials/blix_essentials.dart';


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

enum SubscriptionStatus {
  kNotActive,
  kActive,
  kPending,
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

  static final int maxDoctorID = 1000;

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

  Future<List<PatientListModel>?>
  getPatients({String doctorOwnerID = "", String userNumber = ""}) async {
    Debug.log("getPatients", overrideColor: Colors.greenAccent);
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
    final newList = PatientListModel.listFromJSON(cnv.jsonDecode(response.response) as List);
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
    final localTimeZoneName = await FlutterNativeTimezone.getLocalTimezone();

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
    final localTimeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    final response = await BlixDBManager.httpPost(
        "fetch_dates.php",
        params: {
          "owner": doctorOwnerID,
          "timeZone": localTimeZoneName,
          "userNumber": userNumber,
        }
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