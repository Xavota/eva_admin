import 'package:blix_essentials/blix_essentials.dart';

class DBManager {
  static DBManager? _instance;

  static DBManager? get instance{
    return _instance ??= DBManager();
  }

  Future<bool?>
  validatePassword(String email, String password) async {
    final response = await BlixDBManager.httpPost(
      "check_password.php",
      params: {
        "email": email,//"test@mail.com",
        "password": password,//"T3s7P4S5w0rd",
        "salt": "quesalado",
      },
      debug: true,
    );
    if (response.errors.isNotEmpty) {
      return null;
    }

    return response.response == "1";
  }

  Future<Map<String, String>?>
  registerDoctor(Map<String, dynamic> data) async {
    return null;
  }
}