import 'package:medicare/db_manager.dart';
import 'package:medicare/helpers/theme/theme_customizer.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';

class LayoutController extends MyController {
  ThemeCustomizer themeCustomizer = ThemeCustomizer();

  DBManager manager = DBManager.instance!;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> scrollKey = GlobalKey();

  PatientListModel? loggedUser;

  bool? premium;
  DateTime? premiumEnd;

  @override
  void onReady() {
    super.onReady();
    ThemeCustomizer.addListener(onChangeTheme);
  }

  void onChangeTheme(ThemeCustomizer oldVal, ThemeCustomizer newVal) {
    themeCustomizer = newVal;
    update();

    if (newVal.rightBarOpen) {
      scaffoldKey.currentState?.openEndDrawer();
    } else {
      scaffoldKey.currentState?.closeEndDrawer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    ThemeCustomizer.removeListener(onChangeTheme);
  }

  void getPremiumStatus() {
    loggedUser =
    AuthService.loggedUserData is PatientListModel ?
    AuthService.loggedUserData as PatientListModel? : null;

    if (loggedUser == null) return;

    final status = manager.patientsPremiumStatus[loggedUser!.userNumber];
    if (status is Future<CachedPremiumValue?>) {
      status.then((status) {
        if (status == null) return;
        premium = status.status == SubscriptionStatus.kActive;
        if (premium!) {
          premiumEnd = status.endTime;
        }
        update();
      });
    }
    else {
      final statusValue = status as CachedPremiumValue;

      premium = statusValue.status == SubscriptionStatus.kActive;
      if (premium!) {
        premiumEnd = statusValue.endTime;
      }
    }
  }
}
