import 'package:medicare/model/user.dart';

import '../storage/local_storage.dart';

import 'package:medicare/db_manager.dart';

class AuthService {
  static bool isLoggedIn = false;

  /*static User get dummyUser =>
      User(-1, "trendx@getappui.com", "Denish", "Navadiya");*/

  static Future<Map<String, String>?> loginUser(
      Map<String, dynamic> data) async {
    final response =
    await DBManager.instance!.validatePassword(data['email'], data['password']);

    if (response == null) {
      return {"email": "Hubo un error con el servidor,"
          " intenta de nuevo más tarde."};
    }

    if (response) {
      isLoggedIn = true;
      await LocalStorage.setLoggedInUser(true);
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

  static Future<void> logoutUser() async {
    isLoggedIn = false;
    await LocalStorage.setLoggedInUser(false);
  }
}
