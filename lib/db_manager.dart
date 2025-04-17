import 'dart:convert' as cnv;

import 'package:blix_essentials/blix_essentials.dart';

import 'package:medicare/model/doctor_model.dart';

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

  Future<bool?>
  validatePasswordAdmin(String email, String password) async {
    final response = await BlixDBManager.httpPost(
      "check_password_admin.php",
      params: {
        "email": email,//"test@mail.com",
        "password": password,//"T3s7P4S5w0rd",
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }

    return response.response == "1";
  }

  Future<bool?>
  validatePasswordUser(String userNumber, String password) async {
    final response = await BlixDBManager.httpPost(
      "check_password_user.php",
      params: {
        "userNumber": userNumber,//"test@mail.com",
        "password": password,//"T3s7P4S5w0rd",
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }

    return response.response == "1";
  }

  Future<int?>
  getLastDoctorID() async {
    final response = await BlixDBManager.httpPost(
      "fetch_last_doctor_id.php",
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    return int.tryParse(response.response);
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
      debug: true,
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
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      Map<String, String> r = {};
      for (final e in response.errors) {
        if (e == "Missing info") {
          r.addAll({"server": "Información faltante"});
        }
        else if (e == "No user") {
          r.addAll({"userNumber": "Número de inexistente"});
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
  getDoctors() async {
    final response = await BlixDBManager.httpPost(
      "fetch_doctors.php",
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }
    _doctors = DoctorModel.listFromJSON(cnv.jsonDecode(response.response) as List);
    return _doctors;
  }

  Future<bool> changeDoctorStatus(int userNumber, bool newStatus) async {
    final response = await BlixDBManager.httpPost(
      "change_doctor_status.php",
      params: {
        "number": userNumber.toString(),
        "newStatus": newStatus ? "1" : "0",
      },
      debug: true,
    );
    return response.errors.isEmpty;
  }
}