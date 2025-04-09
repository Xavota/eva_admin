import 'package:medicare/helpers/localizations/language.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/helpers/theme/theme_customizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
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
    DateTime? loggedTime = DateTime.tryParse(preferences.getString(_loggedInUserTimeKey)?? "");
    if (loggedTime != null && DateTime.now().difference(loggedTime).inMinutes < 15) {
      AuthService.isLoggedIn = preferences.getBool(_loggedInUserKey) ?? false;
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
}
