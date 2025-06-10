import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:medicare/helpers/services/auth_services.dart';


import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_flex.dart';
import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/helpers/widgets/my_form.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:medicare/controller/ui/secretary_add_controller.dart';


import 'package:blix_essentials/blix_essentials.dart';


class SecretaryAddScreen extends StatefulWidget {
  const SecretaryAddScreen({super.key});

  @override
  State<SecretaryAddScreen> createState() => _SecretaryAddScreenState();
}

class _SecretaryAddScreenState extends State<SecretaryAddScreen> with UIMixin {
  SecretaryAddController controller = Get.put(SecretaryAddController());

  bool fistBuild = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fistBuild) {
        fistBuild = false;
        controller.clearForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_secretary_add_controller',
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Registrar Secretari@",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Registrar Secretari@', active: true),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: MyContainer(
                  paddingAll: 20,
                  borderRadiusAll: 12,
                  child: MyForm(
                    addNewFormKey: controller.addNewFormKey,
                    disposeFormKey: controller.disposeFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium("Información Básica", fontWeight: 600),
                        MySpacing.height(20),
                        MyFlex(
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  commonTextField(
                                    readOnly: true,
                                    validator: controller.basicValidator.getValidation("userNumber"),
                                    teController: controller.basicValidator.getController("userNumber"),
                                    title: "Número de Usuario",
                                    hintText: "Error calculando número de usuario",
                                    prefixIcon: Icon(Icons.numbers_sharp, size: 16),
                                    integer: true,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Nombre Completo", hintText: "Nombre completo",
                                    validator: controller.basicValidator.getValidation("fullName"),
                                    teController: controller.basicValidator.getController("fullName"),
                                    prefixIcon: Icon(LucideIcons.user_round, size: 16),
                                  ),
                                ],
                              ),
                            ),
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  commonTextField(
                                    validator: controller.basicValidator.getValidation("pin"),
                                    teController: controller.basicValidator.getController("pin"),
                                    title: "NIP", hintText: "NIP",
                                    prefixIcon: Icon(LucideIcons.lock, size: 16),
                                    integer: true, length: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MyContainer(
                              onTap: () {
                                controller.checkExistence().then((exists) {
                                  if (exists == null) {
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, "Hubo un error con el servidor. Inténtelo de nuevo más tarde.", contentTheme.danger);
                                  }
                                  else if (exists) {
                                    _showReplaceAlert(() => _doRegister(true));
                                  }
                                  else {
                                    _doRegister();
                                  }
                                });
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("Registrar", color: contentTheme.onPrimary, fontWeight: 600),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _doRegister([bool doUpdate = false]) {
    controller.onRegister(doUpdate).then((validationError) {
      if (validationError != null) {
        if (!mounted) return;
        simpleSnackBar(context, validationError, contentTheme.danger);
      }
      else {
        controller.calculateUserID();
        controller.manager.getSecretary(doctorOwnerID: AuthService.loggedUserNumber);
        if (!mounted) return;
        simpleSnackBar(context, "Secretari@ registrado con éxito", contentTheme.success);
      }
    });
  }

  Widget commonTextField({
    String? title, String? hintText, bool readOnly = false,
    String? Function(String?)? validator, Widget? prefixIcon,
    void Function()? onTap, TextEditingController? teController,
    bool integer = false, bool floatingPoint = false, int? length}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(title ?? "", fontWeight: 600, muted: true),
        MySpacing.height(8),
        TextFormField(
          validator: validator,
          readOnly: readOnly,
          onTap: onTap ?? () {},
          controller: teController,
          keyboardType: integer ? TextInputType.phone : null,
          maxLength: length != null ? (length + (!integer && floatingPoint ? 3 : 0)) : null,
          inputFormatters: integer ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
              : (floatingPoint ? <TextInputFormatter>[FloatingPointTextInputFormatter(maxDigitsBeforeDecimal: length, maxDigitsAfterDecimal: 2)] : null),
          style: MyTextStyle.bodySmall(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: hintText,
            counterText: "",
            hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
            isCollapsed: true,
            isDense: true,
            prefixIcon: prefixIcon,
            contentPadding: MySpacing.all(16),
          ),
        ),
      ],
    );
  }


  void _showReplaceAlert(void Function() onContinue) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: MySpacing.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyText.labelLarge(
                            'Advertencia', fontWeight: 600,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            LucideIcons.x,
                            size: 20,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0, thickness: 1),
                  Padding(
                    padding: MySpacing.all(16),
                    child: MyText.bodySmall(controller.replaceAlertText, fontWeight: 600),
                  ),
                  Divider(height: 0, thickness: 1),
                  Padding(
                    padding: MySpacing.only(right: 20, bottom: 12, top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyButton(
                          onPressed: () => Get.back(),
                          elevation: 0,
                          borderRadiusAll: 8,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor: colorScheme.secondaryContainer,
                          child: MyText.labelMedium(
                            "Cancelar",
                            fontWeight: 600,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        MySpacing.width(16),
                        MyButton(
                          onPressed: () {
                            Get.back();
                            onContinue();
                          },
                          elevation: 0,
                          borderRadiusAll: 8,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor: colorScheme.primary,
                          child: MyText.labelMedium(
                            "Registrar",
                            fontWeight: 600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
