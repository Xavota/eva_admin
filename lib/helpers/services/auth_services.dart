import 'package:medicare/model/user.dart';

import '../storage/local_storage.dart';

import 'package:medicare/db_manager.dart';

enum LoginType  {
  kNone,
  kAdmin,
  kDoctor,
  kUser,
}

class AuthService {
  static LoginType loginType = LoginType.kNone;

  //static bool isLoggedInAdmin = false;
  //static bool isLoggedIn = false;

  static int maxDoctorNumber = 1000;


  /*static User get dummyUser =>
      User(-1, "trendx@getappui.com", "Denish", "Navadiya");*/

  static Future<void> logout() async {
    switch (loginType) {
      case LoginType.kNone: return;
      case LoginType.kAdmin:
        await LocalStorage.setLoggedInAdmin(false);
      case LoginType.kDoctor:
        await LocalStorage.setLoggedInUser(false);
      case LoginType.kUser:
        await LocalStorage.setLoggedInUser(false);
    }
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
      if (loginType != LoginType.kNone) {
        logout();
      }
      loginType = LoginType.kAdmin;
      await LocalStorage.setLoggedInAdmin(true);
      return null;
    }

    return {"password": "Correo o contraseña inválidos."};
  }

  static Future<Map<String, String>?> loginUser(
      Map<String, dynamic> data) async {
    final response =
    await DBManager.instance!.validatePasswordUser(data['userNumber'], data['password']);

    if (response == null) {
      return {"server": "Hubo un error con el servidor,"
          " intenta de nuevo más tarde."};
    }

    if (response) {
      /*isLoggedIn = true;
      await LocalStorage.setLoggedInUser(true);
      return null;*/
      if (loginType != LoginType.kNone) {
        logout();
      }
      int userNumber = int.parse(data['userNumber']);

      if (userNumber <= maxDoctorNumber) {
        loginType = LoginType.kDoctor;
        await LocalStorage.setLoggedInDoctor(true);
      }
      else {
        loginType = LoginType.kUser;
        await LocalStorage.setLoggedInUser(true);
      }
      return null;
    }

    return {"password": "Correo o contraseña inválidos."};

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

  /*static Future<void> logoutUser() async {
    isLoggedIn = false;
    await LocalStorage.setLoggedInUser(false);
  }*/
}
