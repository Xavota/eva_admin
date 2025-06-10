import 'package:flutter/material.dart';

import 'package:medicare/model/admin_model.dart';

import '../storage/local_storage.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';

enum LoginType  {
  kNone,
  kAdmin,
  kDoctor,
  kPatient,
  kSecretary,
}

extension LoginTypeExtension on LoginType {
  static LoginType? tryParse(String name) {
    for (final e in LoginType.values) {
      if (e.name == name) return e;
    }
    return null;
  }
}

class AuthService {
  static LoginType _loginType = LoginType.kNone;
  static LoginType get loginType {
    if (_loginType == LoginType.kNone ||
        (loggedUserNumber.isEmpty) == (_loginType == LoginType.kAdmin)) {
      return _loginType;
    }
    return LoginType.kNone;
  }
  static set loginType(LoginType value) {
    _loginType = value;
  }
  static String loggedUserNumber = "";

  static dynamic loggedUserData;

  //static bool isLoggedInAdmin = false;
  //static bool isLoggedIn = false;


  /*static User get dummyUser =>
      User(-1, "trendx@getappui.com", "Denish", "Navadiya");*/

  static Future<void> logout() async {
    if (_loginType == LoginType.kNone) return;

    await LocalStorage.setLoggedIn(LoginType.kNone);
    _loginType = LoginType.kNone;
    loggedUserNumber = "";
    loggedUserData = null;
    Debug.log("loggedUserData $loggedUserData", overrideColor: Colors.green);
  }

  static Future<Map<String, String>?> loginAdmin(
      Map<String, dynamic> data) async {
    final response =
    await DBManager.instance!.validatePasswordAdmin(data['email'], data['password']);

    if (response == null) {
      return {"server": "Hubo un error con el servidor,"
          " intenta de nuevo más tarde."};
    }

    if (response) {
      logout();

      _loginType = LoginType.kAdmin;
      await LocalStorage.setLoggedIn(_loginType);

      loggedUserData = AdminModel(0, "Admin", data['email']);

      return null;
    }

    return {"password": "Correo o contraseña inválidos."};
  }

  static Future<Map<String, String>?> loginUser(
      Map<String, dynamic> data) async {
    final response =
    await DBManager.instance!.validatePasswordUser(data['userNumber'], data['pin']);
    Debug.log(response?? "", overrideColor: Colors.lightGreen);

    if (response == null) {
      return {"server": "Hubo un error con el servidor,"
          " intenta de nuevo más tarde"};
    }
    if (response == "archived") {
      return {"server": "El usuario con este número está archivado. Contacte con su médico"};
    }
    if (response == "0") {
      return {"pin": "NIP o usuario inválidos, intente de nuevo o contacte con su médico"};
    }

    logout();

    loggedUserNumber = data['userNumber'];
    _loginType = response == "1" ?
    LoginType.kDoctor : (response == "2" ?
    LoginType.kPatient : LoginType.kSecretary);

    final dataErrors = await updateLoggedUserData();
    if (dataErrors != null) {
      return dataErrors;
    }

    await LocalStorage.setLoggedIn(_loginType, loggedUserNumber);
    return null;


    /*await Future.delayed(Duration(seconds: 1));
    if (data['email'] != dummyUser.email) {
      return {"email": "This email is not registered"};
    } else if (data['password'] != "1234567") {
      return {"password": "Password is incorrect"};
    }

    isLoggedIn = true;
    await LocalStorage.setLoggedInUser(true);
    return null;*/
  }

  static Future<Map<String, String>?> updateLoggedUserData() async {
    if (_loginType == LoginType.kDoctor) {
      final data = await DBManager.instance!.getDoctors(userNumber: loggedUserNumber);
      if (data == null || data.length != 1) {
        loggedUserNumber = "";
        _loginType = LoginType.kNone;
        return {"pin": "NIP o usuario inválidos, intente de nuevo o contacte con su médico"};
      }
      loggedUserData = data[0];
      Debug.log("loggedUserData $loggedUserData", overrideColor: Colors.green);
    }
    else if (_loginType == LoginType.kSecretary) {
      final data = await DBManager.instance!.getSecretary(userNumber: loggedUserNumber);
      if (data == null) {
        loggedUserNumber = "";
        _loginType = LoginType.kNone;
        return {"pin": "NIP o usuario inválidos, intente de nuevo o contacte con su médico"};
      }
      loggedUserData = data;
      Debug.log("loggedUserData $loggedUserData", overrideColor: Colors.green);
    }
    else if (_loginType == LoginType.kPatient) {
      final data = await DBManager.instance!.getPatients(userNumber: loggedUserNumber);
      if (data == null || data.length != 1) {
        loggedUserNumber = "";
        _loginType = LoginType.kNone;
        return {"pin": "NIP o usuario inválidos, intente de nuevo o contacte con su médico"};
      }
      loggedUserData = data[0];
      Debug.log("loggedUserData $loggedUserData", overrideColor: Colors.green);
    }

    return null;
  }

  /*static Future<void> logoutUser() async {
    isLoggedIn = false;
    await LocalStorage.setLoggedInUser(false);
  }*/
}
