import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicare/controller/auth/login_controller.dart';
import 'package:medicare/helpers/theme/app_themes.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/views/layout/auth_layout.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin, UIMixin {
  late LoginController controller;

  @override
  void initState() {
    controller = Get.put(LoginController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AuthLayout(
          child: GetBuilder(
            init: controller,
            builder: (controller) {
              return Stack(
                children: [
                  Padding(
                    padding: MySpacing.all(24),
                    child: Form(
                      key: controller.basicValidator.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyText.headlineSmall("LogIn", fontWeight: 600),
                          MySpacing.height(20),
                          MyText.bodySmall("Bienvenido a Eva!\nPor favor ingrese sus credenciales.", muted: true),
                          MySpacing.height(20),
                          MyText.labelMedium("Número de usuario", fontWeight: 600, muted: true),
                          MySpacing.height(8),
                          TextFormField(
                            validator: controller.basicValidator.getValidation('userNumber'),
                            controller: controller.basicValidator.getController('userNumber'),
                            keyboardType: TextInputType.emailAddress,
                            style: MyTextStyle.bodySmall(),
                            decoration: InputDecoration(
                              labelText: "Número de usuario",
                              labelStyle: MyTextStyle.bodySmall(xMuted: true),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(LucideIcons.id_card, size: 20),
                              contentPadding: MySpacing.all(16),
                              isCollapsed: true,
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                            ),
                          ),
                          MySpacing.height(20),
                          MyText.labelMedium("NIP", fontWeight: 600, muted: true),
                          MySpacing.height(8),
                          TextFormField(
                            validator: controller.basicValidator.getValidation('pin'),
                            controller: controller.basicValidator.getController('pin'),
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                            maxLength: 4,
                            obscureText: !controller.showPassword,
                            style: MyTextStyle.bodySmall(),
                            decoration: InputDecoration(
                              labelText: "NIP",
                              labelStyle: MyTextStyle.bodySmall(xMuted: true),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(
                                LucideIcons.lock,
                                size: 20,
                              ),
                              suffixIcon: InkWell(
                                onTap: controller.onChangeShowPassword,
                                child: Icon(
                                  controller.showPassword ? LucideIcons.eye : LucideIcons.eye_off,
                                  size: 20,
                                ),
                              ),
                              contentPadding: MySpacing.all(16),
                              isCollapsed: true,
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                            ),
                          ),
                          MySpacing.height(10),
                          //MyText.bodySmall("* Para restablecer tu contraseña, contacta al equipo de desarrollo.", fontWeight: 600, muted: true),
                          /*Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => controller.onChangeCheckBox(!controller.isChecked),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      onChanged: controller.onChangeCheckBox,
                                      value: controller.isChecked,
                                      fillColor: WidgetStateProperty.resolveWith((states) {
                                        if (!states.contains(WidgetState.selected)) {
                                          return Colors.white;
                                        }
                                        return null;
                                      }),
                                      activeColor: theme.colorScheme.primary,
                                      overlayColor: WidgetStatePropertyAll(Colors.white),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: getCompactDensity,
                                    ),
                                    MySpacing.width(8),
                                    MyText.labelMedium("Remember Me", fontWeight: 600, muted: true),
                                  ],
                                ),
                              ),
                              MyButton.text(
                                onPressed: controller.goToForgotPassword,
                                elevation: 0,
                                padding: MySpacing.xy(8, 0),
                                splashColor: contentTheme.secondary.withOpacity(0.1),
                                child: MyText.labelMedium('Forgot password?', fontWeight: 600, muted: true),
                              ),
                            ],
                          ),*/
                          MySpacing.height(28),
                          Center(
                            child: MyButton.rounded(
                              onPressed: () async {
                                controller.onLogin().then((serverError) {
                                  if (serverError != null && context.mounted) {
                                    simpleSnackBar(context, serverError, contentTheme.danger);
                                  }
                                });
                              },
                              elevation: 0,
                              padding: MySpacing.xy(20, 16),
                              backgroundColor: contentTheme.primary,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.loading
                                      ? SizedBox(
                                          height: 14,
                                          width: 14,
                                          child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 1.2),
                                        )
                                      : Container(),
                                  if (controller.loading) MySpacing.width(16),
                                  MyText.labelMedium('Ingresar',fontWeight: 600, color: contentTheme.onPrimary),
                                ],
                              ),
                            ),
                          ),
                          /*Center(
                            child: MyButton.text(
                              onPressed: controller.gotoRegister,
                              elevation: 0,
                              padding: MySpacing.x(16),
                              splashColor: contentTheme.secondary.withOpacity(0.1),
                              child: MyText.labelMedium('No tengo una cuenta', color: contentTheme.secondary),
                            ),
                          ),*/
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed('/panel');
                    },
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      color: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
