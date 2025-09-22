import 'dart:developer';
import 'dart:math' as math;

class MyStringUtils {
  static bool isFirstCapital(String string) {
    if (string.codeUnitAt(0) >= 65 && string.codeUnitAt(0) <= 90) {
      return true;
    }
    return false;
  }

  static bool isFirstLetter(String string) {
    if (string.codeUnitAt(0) >= 0 && string.codeUnitAt(0) <= 9) {
      return true;
    }
    return false;
  }

  static bool isAlphabetIncluded(String string) {
    string = string.toUpperCase();
    for (int i = 0; i < string.length; i++) {
      if (string.codeUnitAt(i) >= 65 && string.codeUnitAt(i) <= 90) {
        return true;
      }
    }
    return false;
  }

  static bool isDigitIncluded(String string) {
    for (int i = 0; i < string.length; i++) {
      if (string.codeUnitAt(i) >= 0 && string.codeUnitAt(i) <= 9) {
        return true;
      }
    }
    return false;
  }

  static bool isSpecialCharacterIncluded(String string) {
    String ch = "~`!@#\$%^&*.?_";

    for (int i = 0; i < string.length; i++) {
      if (ch.contains(string[i])) {
        return true;
      }
    }
    return false;
  }

  static bool isIncludedCharactersPresent(
      String string, List<String>? includeCharacters) {
    if (includeCharacters == null) {
      return false;
    }

    for (int i = 0; i < string.length; i++) {
      if (includeCharacters.contains(string[i])) {
        return true;
      }
    }
    return false;
  }

  static bool isIgnoreCharactersPresent(
      String string, List<String>? ignoreCharacters) {
    if (ignoreCharacters == null) {
      return false;
    }

    for (int i = 0; i < string.length; i++) {
      if (ignoreCharacters.contains(string[i])) {
        return true;
      }
    }
    return false;
  }

  static bool checkMaxAlphabet(String string, int maxAlphabet) {
    int counter = 0;
    string = string.toUpperCase();
    for (int i = 0; i < string.length; i++) {
      if (string.codeUnitAt(i) >= 65 && string.codeUnitAt(i) <= 90) {
        counter++;
      }
    }
    if (counter <= maxAlphabet) {
      return true;
    }
    return false;
  }

  static bool checkMaxDigit(String string, int maxDigit) {
    int counter = 0;

    for (int i = 0; i < string.length; i++) {
      if (string.codeUnitAt(i) >= 0 && string.codeUnitAt(i) <= 9) {
        counter++;
      }
    }
    if (counter <= maxDigit) {
      return true;
    }
    return false;
  }

  static bool checkMinAlphabet(String string, int minAlphabet) {
    int counter = 0;
    string = string.toUpperCase();
    for (int i = 0; i < string.length; i++) {
      if (string.codeUnitAt(i) >= 65 && string.codeUnitAt(i) <= 90) {
        counter++;
      }
    }
    if (counter >= minAlphabet) {
      return true;
    }
    return false;
  }

  static bool checkMinDigit(String string, int minDigit) {
    int counter = 0;
    for (int i = 0; i < string.length; i++) {
      if (string.codeUnitAt(i) >= 0 && string.codeUnitAt(i) <= 9) {
        counter++;
      }
    }
    if (counter >= minDigit) {
      return true;
    }
    return false;
  }

  static bool validateString(
    String string, {
    int minLength = 8,
    int maxLength = 20,
    bool firstCapital = false,
    bool firstDigit = false,
    bool includeDigit = false,
    bool includeAlphabet = false,
    bool includeSpecialCharacter = false,
    List<String>? includeCharacters,
    List<String>? ignoreCharacters,
    int minAlphabet = 5,
    int maxAlphabet = 20,
    int minDigit = 0,
    int maxDigit = 20,
  }) {
    if (string.length < minLength) {
      return false;
    }

    if (string.length > maxLength) {
      return false;
    }

    if (firstCapital && !isFirstCapital(string)) {
      return false;
    }

    if (firstDigit && !isFirstLetter(string)) {
      return false;
    }

    if (includeAlphabet && !isAlphabetIncluded(string)) {
      return false;
    }

    if (includeDigit && !isDigitIncluded(string)) {
      return false;
    }

    if (includeSpecialCharacter && !isSpecialCharacterIncluded(string)) {
      return false;
    }

    if (!isIncludedCharactersPresent(string, includeCharacters)) {
      return false;
    }

    if (isIgnoreCharactersPresent(string, ignoreCharacters)) {
      return false;
    }

    if (!checkMaxAlphabet(string, maxAlphabet)) {
      return false;
    }

    if (!checkMinAlphabet(string, minAlphabet)) {
      return false;
    }

    if (!checkMaxDigit(string, maxAlphabet)) {
      return false;
    }

    if (!checkMinDigit(string, minAlphabet)) {
      return false;
    }

    return true;
  }

  static bool isEmail(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{1,}))$';
    RegExp regex = RegExp(pattern as String);
    log(regex.hasMatch(email).toString());
    return regex.hasMatch(email);
  }

  static bool validateStringRange(String text,
      [int minLength = 8, int maxLength = 20]) {
    return text.length >= minLength && text.length <= maxLength;
  }

  static String addZerosAtFront(int number, {int? lengthRequired, int? addedZeros}) {
    if (lengthRequired != null) {
      String r = number.toString();
      int zerosNeeded = lengthRequired - r.length;
      if (zerosNeeded <= 0) return r;
      for (int i = 0; i < zerosNeeded; ++i) {
        r = "0$r";
      }
      return r;
    }
    else if (addedZeros != null) {
      String r = number.toString();
      for (int i = 0; i < addedZeros; ++i) {
        r = "0$r";
      }
      return r;
    }
    return number.toString();
  }

  static (String, bool) limitLines(String text, [int maxLines = 4]) {
    final lines = text.split('\n');
    return (lines
        .sublist(0, math.min(lines.length, maxLines))
        .map((e) => e.trim())
        .join('\n'),
    lines.length > maxLines);
  }

  static String textCutout(String plainText, [int maxChars = 256]) {
    final trimmedText = plainText.trim().replaceAll(RegExp(r'(\n)+'), '\n');
    if (trimmedText.length <= maxChars) {
      final r = limitLines(trimmedText);
      return "${r.$1}${r.$2 ? "${r.$1.endsWith('.') ? " " : ""}..." : ""}";
    }

    String r = trimmedText.substring(0, maxChars);
    final limited = limitLines(r);
    r = limited.$1.substring(0, limited.$2 ? null : limited.$1.lastIndexOf(' ')).trim();
    return "$r${r.endsWith('.') ? " " : ""}...";
  }
}
