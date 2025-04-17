import 'package:medicare/helpers/localizations/language.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/helpers/theme/theme_customizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _loggedInAdminKey = "admin";
  static const String _loggedInAdminTimeKey = "admin_time";
  static const String _loggedInDoctorKey = "doctor";
  static const String _loggedInDoctorTimeKey = "doctor_time";
  static const String _loggedInUserKey = "user";
  static const String _loggedInUserTimeKey = "user_time";
  static const String _themeCustomizerKey = "theme_customizer";
  static const String _languageKey = "lang_code";

  static SharedPreferences? _preferencesInstance;

  static SharedPreferences get preferences {
    if (_preferencesInstance == null) {
      throw ("Call LocalStorage.init() to initialize local storage");
    }
    return _preferencesInstance!;
  }

  static Future<void> init() async {
    _preferencesInstance = await SharedPreferences.getInstance();
    await initData();
  }

  static Future<void> initData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    DateTime? loggedTime = DateTime.tryParse(preferences.getString(_loggedInAdminTimeKey)?? "");
    if (loggedTime != null && DateTime.now().difference(loggedTime).inMinutes < 15) {
      //AuthService.isLoggedInAdmin = preferences.getBool(_loggedInAdminKey) ?? false;
      final isLoggedIn = preferences.getBool(_loggedInAdminKey)?? false;
      AuthService.loginType = isLoggedIn ? LoginType.kAdmin : AuthService.loginType;
    }

    loggedTime = DateTime.tryParse(preferences.getString(_loggedInDoctorTimeKey)?? "");
    if (AuthService.loginType == LoginType.kNone && loggedTime != null && DateTime.now().difference(loggedTime).inMinutes < 15) {
      //AuthService.isLoggedIn = preferences.getBool(_loggedInDoctorKey) ?? false;
      final isLoggedIn = preferences.getBool(_loggedInDoctorKey)?? false;
      AuthService.loginType = isLoggedIn ? LoginType.kDoctor : AuthService.loginType;
    }

    loggedTime = DateTime.tryParse(preferences.getString(_loggedInUserTimeKey)?? "");
    if (AuthService.loginType == LoginType.kNone && loggedTime != null && DateTime.now().difference(loggedTime).inMinutes < 15) {
      //AuthService.isLoggedIn = preferences.getBool(_loggedInUserKey) ?? false;
      final isLoggedIn = preferences.getBool(_loggedInUserKey)?? false;
      AuthService.loginType = isLoggedIn ? LoginType.kUser : AuthService.loginType;
    }

    ThemeCustomizer.fromJSON(preferences.getString(_themeCustomizerKey));
  }

  static Future<bool> setLoggedInUser(bool loggedIn) async {
    if (loggedIn) {
      if (!await preferences.setString(_loggedInUserTimeKey, DateTime.now().toString())) {
        return false;
      }
    }
    return preferences.setBool(_loggedInUserKey, loggedIn);
  }

  static Future<bool> setLoggedInDoctor(bool loggedIn) async {
    if (loggedIn) {
      if (!await preferences.setString(_loggedInDoctorTimeKey, DateTime.now().toString())) {
        return false;
      }
    }
    return preferences.setBool(_loggedInDoctorKey, loggedIn);
  }

  static Future<bool> setLoggedInAdmin(bool loggedIn) async {
    if (loggedIn) {
      if (!await preferences.setString(_loggedInAdminTimeKey, DateTime.now().toString())) {
        return false;
      }
    }
    return preferences.setBool(_loggedInAdminKey, loggedIn);
  }

  static Future<bool> setCustomizer(ThemeCustomizer themeCustomizer) {
    return preferences.setString(_themeCustomizerKey, themeCustomizer.toJSON());
  }

  static Future<bool> setLanguage(Language language) {
    return preferences.setString(_languageKey, language.locale.languageCode);
  }

  static String? getLanguage() {
    return preferences.getString(_languageKey);
  }

  static Future<bool> removeLoggedInUser() async {
    return preferences.remove(_loggedInUserKey);
  }

  static Future<bool> removeLoggedInDoctor() async {
    return preferences.remove(_loggedInDoctorKey);
  }

  static Future<bool> removeLoggedInAdmin() async {
    return preferences.remove(_loggedInAdminKey);
  }
}
