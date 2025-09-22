import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';
import 'package:medicare/helpers/services/auth_services.dart';


import 'package:medicare/helpers/theme/app_themes.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

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

import 'package:medicare/model/daily_record_model.dart';

import 'package:medicare/controller/ui/patient_daily_record_controller.dart';


import 'package:blix_essentials/blix_essentials.dart';


class PatientDalyRecordScreen extends StatefulWidget {
  const PatientDalyRecordScreen({super.key});

  @override
  State<PatientDalyRecordScreen> createState() => _PatientDalyRecordScreenState();
}

class _PatientDalyRecordScreenState extends State<PatientDalyRecordScreen> with UIMixin {
  PatientDalyRecordController controller = Get.put(PatientDalyRecordController());

  bool fistBuild = true;

  @override
  void initState() {
    super.initState();

    controller.getTodayRecord().then((_) { setState(() {}); });

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fistBuild) {
        fistBuild = false;
        controller.clearForm();
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_patient_edit_controller',
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Edición de Tratante",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Edición Tratante', active: true),
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
                    //key: controller.basicValidator.formKey,
                    addNewFormKey: controller.addNewFormKey,
                    disposeFormKey: controller.disposeFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleLarge("Registro del Día ${dateFormatter.format(DateTime.now())}", fontWeight: 600),
                        MySpacing.height(20),
                        MyText.titleMedium("Datos Fisiológicos", fontWeight: 600),
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
                                    title: "Peso Diario (Kg)", hintText: "Peso diario",
                                    validator: controller.basicValidator.getValidation("weight"),
                                    teController: controller.basicValidator.getController("weight"),
                                    prefixIcon: Icon(Icons.scale, size: 16),
                                    floatingPoint: true, length: 3,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Cintura (cm)", hintText: "Cintura",
                                    validator: controller.basicValidator.getValidation("waist"),
                                    teController: controller.basicValidator.getController("waist"),
                                    prefixIcon: Icon(LucideIcons.ruler, size: 16),
                                    floatingPoint: true, length: 3,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Presión Arterial Sistólica (mmHg)", hintText: "Presión Arterial Sistólica",
                                    validator: controller.basicValidator.getValidation("systolicBloodPressure"),
                                    teController: controller.basicValidator.getController("systolicBloodPressure"),
                                    prefixIcon: Icon(LucideIcons.heart_pulse, size: 16),
                                    floatingPoint: true, length: 3,
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
                                    title: "Presión Arterial Diastólica (mmHg)", hintText: "Presión Arterial Diastólica",
                                    validator: controller.basicValidator.getValidation("diastolicBloodPressure"),
                                    teController: controller.basicValidator.getController("diastolicBloodPressure"),
                                    prefixIcon: Icon(LucideIcons.heart_pulse, size: 16),
                                    floatingPoint: true, length: 3,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Azúcar en Sangre (mg/dL)", hintText: "Azúcar en Sangre",
                                    validator: controller.basicValidator.getValidation("sugarLevel"),
                                    teController: controller.basicValidator.getController("sugarLevel"),
                                    prefixIcon: Icon(LucideIcons.dessert, size: 16),
                                    floatingPoint: true, length: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(20),
                        MyText.titleMedium("Bienestar", fontWeight: 600),
                        MySpacing.height(20),
                        MyFlex(
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.labelMedium("Estado de ánimo", fontWeight: 600, muted: true),
                                  MySpacing.height(15),
                                  Wrap(
                                    spacing: 16,
                                    children: EmotionalState.values.map((emotion) => InkWell(
                                      onTap: () => controller.onChangeEmotionalState(emotion),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio<EmotionalState>(
                                            value: emotion,
                                            activeColor: theme.colorScheme.primary,
                                            groupValue: controller.emotionalState,
                                            onChanged: (value) => controller.onChangeEmotionalState(value),
                                            visualDensity: getCompactDensity,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          MySpacing.width(8),
                                          MyText.labelMedium(
                                            emotion.name.capitalize!,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ).toList(),
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
                                    title: "Horas de Sueño", hintText: "Horas de sueño",
                                    validator: controller.basicValidator.getValidation("sleepTime"),
                                    teController: controller.basicValidator.getController("sleepTime"),
                                    prefixIcon: Icon(LucideIcons.timer, size: 16),
                                    floatingPoint: true, length: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(20),
                        MyText.titleMedium("Hábitos", fontWeight: 600),
                        MySpacing.height(20),
                        MyFlex(
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.labelMedium("Ingesta de Medicamentos", fontWeight: 600, muted: true),
                                  MySpacing.height(15),
                                  Wrap(
                                    spacing: 16,
                                    children: [false, true].map((takenMedicine) => InkWell(
                                      onTap: () => controller.onChangeMedications(takenMedicine),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio<bool>(
                                            value: takenMedicine,
                                            activeColor: theme.colorScheme.primary,
                                            groupValue: controller.medications,
                                            onChanged: (value) => controller.onChangeMedications(value),
                                            visualDensity: getCompactDensity,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          MySpacing.width(8),
                                          MyText.labelMedium(
                                            takenMedicine ? "Sí" : "No",
                                          ),
                                        ],
                                      ),
                                    ),
                                    ).toList(),
                                  ),
                                ],
                              ),
                            ),
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.labelMedium("Ejercicio Realizado", fontWeight: 600, muted: true),
                                  MySpacing.height(15),
                                  Wrap(
                                    spacing: 16,
                                    children: [false, true].map((exercise) => InkWell(
                                      onTap: () => controller.onChangeExercise(exercise),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio<bool>(
                                            value: exercise,
                                            activeColor: theme.colorScheme.primary,
                                            groupValue: controller.exercise,
                                            onChanged: (value) => controller.onChangeExercise(value),
                                            visualDensity: getCompactDensity,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          MySpacing.width(8),
                                          MyText.labelMedium(
                                            exercise ? "Sí" : "No",
                                          ),
                                        ],
                                      ),
                                    ),
                                    ).toList(),
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
                                controller.onSave().then((validationError) {
                                  DBManager.instance!.getPatientDailyRecords(AuthService.loggedUserNumber);
                                  if (!context.mounted) return;
                                  if (validationError != null) {
                                    simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                                  }
                                  else {
                                    simpleSnackBar(context, "Datos diários anotados con éxito", contentTheme.success);// Color(0xFF35639D));
                                  }
                                });
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("Guardar", color: contentTheme.onPrimary, fontWeight: 600),
                            ),
                            /*MySpacing.width(20),
                            MyContainer(
                              onTap: () {},
                              padding: MySpacing.xy(12, 8),
                              borderRadiusAll: 8,
                              color: contentTheme.secondary.withAlpha(32),
                              child: MyText.labelMedium("Cancelar", color: contentTheme.secondary, fontWeight: 600),
                            ),*/
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
}
