import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false, loading = false;

  bool confirmPassword = false;

  @override
  void onInit() {
    super.onInit();
    basicValidator.addField(
      'password',
      required: true,
      validators: [
        MyLengthValidator(min: 6, max: 10),
      ],
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'confirm_password',
      required: true,
      label: "Confirm password",
      validators: [
        MyLengthValidator(min: 6, max: 10),
      ],
      controller: TextEditingController(),
    );
  }

  Future<void> onResetPassword() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.addErrors(errors);
        basicValidator.validateForm();
        basicValidator.clearErrors();
      }
      Get.toNamed('/home');
      loading = false;
      update();
    }
  }

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void onConfirmPassword() {
    confirmPassword = !confirmPassword;
    update();
  }
}
