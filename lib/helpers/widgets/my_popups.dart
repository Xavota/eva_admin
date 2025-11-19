import 'package:flutter/material.dart';
import 'package:medicare/helpers/widgets/my_text.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class MyPopups {
  static void simpleToastMessage(String text, Color color, Color textColor, {
    double? width,
    Duration duration = const Duration(milliseconds: 1200),
    Animation<double>? animation}) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        width: width,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        animation: animation,
        content: MyText.labelLarge(
            text, fontWeight: 600, color: textColor),
        backgroundColor: color,
      ),
    );
  }
}