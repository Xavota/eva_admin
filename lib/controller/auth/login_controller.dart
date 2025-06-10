import 'package:flutter/material.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:get/get.dart';
import 'package:medicare/views/my_controller.dart';

class LoginController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false, loading = false;//, isChecked = false;

  //final String _dummyEmail = "trendx@getappui.com";
  //final String _dummyPassword = "1234567";

  @override
  void onInit() {
    basicValidator.addField('userNumber', required: true, label: "Número de usuario", controller: TextEditingController());

    basicValidator.addField('pin', required: true, label: "NIP", validators: [MyIntegerValidator(exactLength: 4)], controller: TextEditingController());
    super.onInit();
  }

  /*void onChangeCheckBox(bool? value) {
    isChecked = value ?? isChecked;
    update();
  }*/

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  Future<String?> onLogin() async {
    String? validationError;
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        if (errors.containsKey("server")) {
          validationError = errors["server"];
          errors.remove("server");
        }
        if (errors.isNotEmpty) {
          basicValidator.addErrors(errors);
          basicValidator.validateForm();
          basicValidator.clearErrors();
          validationError = "Hay errores en algunos datos";
        }
      }
      else {
        String nextUrl = Uri.parse(ModalRoute.of(Get.context!)?.settings.name ?? "").queryParameters['next'] ??
            (AuthService.loginType == LoginType.kDoctor ? "/doctor/patient/list" :
            (AuthService.loginType == LoginType.kSecretary ? "/secretary/patient/list" :
            (AuthService.loginType == LoginType.kPatient ? "/dates/list" : "")));
        Get.toNamed(
          nextUrl,
        );
      }
      loading = false;
      update();
    }
    else {
      validationError = "Hay errores en algunos datos";
    }

    return validationError;
  }

  void goToForgotPassword() {
    Get.toNamed('/auth/forgot_password');
  }

  void gotoRegister() {
    Get.offAndToNamed('/auth/register_account');
  }
}
