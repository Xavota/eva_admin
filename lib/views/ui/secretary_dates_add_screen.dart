import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:medicare/helpers/widgets/my_popups.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:medicare/app_constant.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/helpers/theme/app_themes.dart';

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

import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/controller/ui/secretary_date_add_controller.dart';


import 'package:blix_essentials/blix_essentials.dart';


class SecretaryDatesAddScreen extends StatefulWidget {
  const SecretaryDatesAddScreen({super.key});

  @override
  State<SecretaryDatesAddScreen> createState() => _SecretaryDatesAddScreenState();
}

class _SecretaryDatesAddScreenState extends State<SecretaryDatesAddScreen> with SingleTickerProviderStateMixin, UIMixin {
  late SecretaryDateAddController stateController;// = Get.put(SecretaryDateAddController(this));

  int instanceIndex = -1;

  // 1 -> initState
  // 2 -> firstFrame
  // 4 -> firstPostFrame
  // 8 -> showSnackBar
  int actionFlags = 0;
  bool hasActionFlag(int flag) => (actionFlags & flag) == flag;
  void toggleActionFlag(int flag) { actionFlags ^= flag; }
  void setActionFlag(int flag, bool set) { actionFlags = set ? actionFlags | flag : actionFlags & (~flag); }
  void executeOnFlagAndToggle(int flag, void Function() onFlag) {
    if (hasActionFlag(flag)) { // firstPostFrame
      setActionFlag(flag, false);
      onFlag();
    }
  }

  String snackBarMsg = "Test snak";
  Color snackBarColor = Colors.green;
  Color snackBarTextColor = Colors.black;



  @override
  void initState() {
    super.initState();

    setActionFlag(7, true); // initState | firstFrame | firstPostFrame

    stateController = Get.put(
      SecretaryDateAddController(),
      tag: 'secretary_date_add_controller',
    );
  }

  void builderInitState(SecretaryDateAddController controller) {
    instanceIndex = controller.contextInstance.addInstance();
    controller.updatePatientsInfo(instanceIndex);
  }

  void builderFirstPostFrame(SecretaryDateAddController controller) {
    controller.clearForm(instanceIndex);
  }

  void builderPostFrame(SecretaryDateAddController controller) {
    executeOnFlagAndToggle(4, () { // firstPostFrame
      builderFirstPostFrame(controller);
    });
    executeOnFlagAndToggle(8, () { // showSnackBar
      MyPopups.simpleToastMessage(snackBarMsg, snackBarColor, snackBarTextColor);
    });

    if (!hasActionFlag(2) && controller.contextInstance.updateInstanceIndex != instanceIndex) return;
    setActionFlag(2, false);
  }

  void builderDispose(SecretaryDateAddController controller) {
    controller.contextInstance.disposeInstance(instanceIndex);
  }


  void prepareSnackBar(SecretaryDateAddController controller, String msg, Color color, Color textColor) {
    setActionFlag(8, true);
    snackBarMsg = msg;
    snackBarColor = color;
    snackBarTextColor = textColor;
    controller.contextInstance.doUpdate(instanceIndex);
  }


  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: stateController,
        tag: 'secretary_date_add_controller',
        dispose: (controller) {
          builderDispose(controller.controller!);
        },
        builder: (controller) {
          executeOnFlagAndToggle(1, () { // initState
            builderInitState(controller);
          });
          WidgetsBinding.instance.addPostFrameCallback((_) { builderPostFrame(controller); });

          double? titlesSize(double? width, double extraPadding) {
            return width == null ? null : width + extraPadding;
          }

          double contentPadding = 20.0;


          final globalKey = controller.contextInstance.getContentKey(instanceIndex, "global");
          final formKey = controller.contextInstance.getFormKey(instanceIndex, "form");
          final globalSize = controller.contextInstance.getContentSize(instanceIndex, "global");

          return Column(
            key: globalKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: SizedBox(
                  width: titlesSize(
                    globalSize?.width,
                    contentPadding,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MyText.titleMedium(
                        "Agendar Cita",
                        fontSize: 18,
                        fontWeight: 600,
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: 'Secretaria'),
                          MyBreadcrumbItem(name: 'Agendar Cita', active: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: MyContainer(
                  paddingAll: 20,
                  borderRadiusAll: 12,
                  child: Form(
                    key: formKey,
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
                                    controller,
                                    title: "Número de Teléfono", hintText: "Número de teléfono",
                                    validator: controller.basicValidator.getValidation("phoneNumber"),
                                    teController: controller.basicValidator.getController("phoneNumber"),
                                    prefixIcon: Icon(LucideIcons.phone, size: 16),
                                    integer: true, length: 10,
                                  ),
                                ],
                              ),
                            ),
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  selectDateTime(
                                    controller,
                                    title: "Fecha de la Cita",
                                    hintText: "Fecha y hora",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(20),
                        MyText.labelMedium("Paciente", fontWeight: 600, muted: true),
                        MySpacing.height(15),
                        RadioGroup(
                          groupValue: controller.data[instanceIndex]!.tempPatient,
                          onChanged: (value) => controller.onChangeTempPatient(instanceIndex, value),
                          child: Wrap(
                            spacing: 16,
                            children: [
                              InkWell(
                                onTap: () => controller.onChangeTempPatient(instanceIndex, false),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<bool>(
                                      value: false,
                                      activeColor: theme.colorScheme.primary,
                                      visualDensity: getCompactDensity,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    MySpacing.width(8),
                                    MyText.labelMedium(
                                      "Registrado",
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => controller.onChangeTempPatient(instanceIndex, true),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      activeColor: theme.colorScheme.primary,
                                      visualDensity: getCompactDensity,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    MySpacing.width(8),
                                    MyText.labelMedium(
                                      "Temporal",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        MySpacing.height(20),
                        MyFlex(
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.data[instanceIndex]!.tempPatient)
                                    commonTextField(
                                      controller,
                                      title: "Nombre Completo", hintText: "Nombre completo",
                                      validator: controller.basicValidator.getValidation("tempFullName"),
                                      teController: controller.basicValidator.getController("tempFullName"),
                                      prefixIcon: Icon(LucideIcons.user_round, size: 16),
                                    ),
                                  if (!controller.data[instanceIndex]!.tempPatient)
                                    selectPatientDropdown(controller),
                                ],
                              ),
                            ),
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.data[instanceIndex]!.tempPatient)
                                    MyText.labelMedium("Motivo de Consulta", fontWeight: 600, muted: true),
                                  if (controller.data[instanceIndex]!.tempPatient)
                                    MySpacing.height(8),
                                  if (controller.data[instanceIndex]!.tempPatient)
                                    consultationReasons(controller),
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
                                controller.onRegister(instanceIndex).then((validationError) {
                                  if (validationError != null) {
                                    prepareSnackBar(controller, validationError, contentTheme.danger, contentTheme.onDanger);
                                  }
                                  else {
                                    controller.manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber);
                                    controller.updatePatientsInfo(instanceIndex);
                                    prepareSnackBar(controller, "Cita agendada con éxito", contentTheme.success, contentTheme.onSuccess);
                                  }
                                });
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("Agendar", color: contentTheme.onPrimary, fontWeight: 600),
                            ),
                            /*MyContainer(
                              onTap: () {
                                controller.getOffAll();
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("getOffAll", color: contentTheme.onPrimary, fontWeight: 600),
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

  Widget commonTextField(SecretaryDateAddController controller, {
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

  Widget selectPatientDropdown(SecretaryDateAddController controller){
    return DropdownButtonFormField<PatientListModel>(
        dropdownColor: contentTheme.background,
        isDense: true,
        style: MyTextStyle.bodySmall(),
        items: controller.data[instanceIndex]!.patients
            .map((patient) => DropdownMenuItem<PatientListModel>(
          value: patient,
          child: MyText.bodySmall("${patient.userNumber} ${patient.fullName}"),
        ))
            .toList(),
        icon: Icon(LucideIcons.chevron_down, size: 20),
        decoration: InputDecoration(
          hintText: "Elige Paciente",
          hintStyle: MyTextStyle.bodySmall(xMuted: true),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: MySpacing.all(12),
          isCollapsed: true,
          isDense: true,
          prefixIcon: Icon(LucideIcons.user, size: 16),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          errorText: controller.basicValidator.getError('userNumber'),
        ),
        onChanged: (value) => controller.onChangeSelectedPatient(instanceIndex, value),
    );
  }

  Widget consultationReasons(SecretaryDateAddController controller) {
    return Container(
      key: ValueKey(controller.data[instanceIndex]!.consultationReasons.join()),
      child: Column(
        children: [
          InputDecorator(
            isEmpty: controller.data[instanceIndex]!.consultationReasons.isEmpty,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: "A qué viene a consulta",
              counterText: "",
              hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
              isCollapsed: true,
              isDense: true,
              prefixIcon: Icon(LucideIcons.heart_pulse, size: 16),
              contentPadding: MySpacing.all(2),
              errorText: controller.basicValidator.getError('tempConsultReasons'),
            ),
            child: MultiSelectDialogField<ConsultationReason>(
              initialValue: controller.data[instanceIndex]!.consultationReasons,
              items: ConsultationReason.values
                  .map((category) => MultiSelectItem<ConsultationReason>(
                category,
                category.name.capitalize!,
              ))
                  .toList(),
              title: Text("Selecciona tus motivos de consulta"),
              confirmText: Text("Confirmar", style: TextStyle(color: contentTheme.primary),),
              cancelText: Text("Cancelar", style: TextStyle(color: contentTheme.danger),),
              searchable: true,
              checkColor: Colors.white,

              selectedColor: contentTheme.primary,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              buttonIcon: Icon(LucideIcons.chevron_down, size: 20),
              buttonText: Text(
                controller.data[instanceIndex]!.consultationReasons.isEmpty ? "" : "Motivos de consutla",
                style: MyTextStyle.bodySmall(xMuted: true),
              ),
              chipDisplay: MultiSelectChipDisplay.none(),
              onConfirm: (values) {
                controller.onConsultationChange(instanceIndex, values);
              },
            ),
          ),
          Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: controller.data[instanceIndex]!.consultationReasons.map<Widget>((item) {
              return InkWell(
                onTap: () {
                  Debug.log("Removing: ${item.name}", overrideColor: Colors.red);
                  controller.removeConsultation(instanceIndex, item);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: contentTheme.background,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        item.name,
                        style: MyTextStyle.bodySmall(),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget selectDateTime(SecretaryDateAddController controller, {String? title, String? hintText}) {
    Debug.log("controller.basicValidator.errors: ${controller.basicValidator.errors}");
    return Container(
      key: ValueKey(controller.data[instanceIndex]!.selectedDate.toString()),
      child: InputDecorator(
        isEmpty: controller.data[instanceIndex]!.selectedDate == null,
        decoration: InputDecoration(
          //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
          hintText: "",
          counterText: "",
          hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
          isCollapsed: true,
          isDense: true,
          //prefixIcon: Icon(LucideIcons.heart_pulse, size: 16),
          contentPadding: MySpacing.all(2),
          errorText: controller.basicValidator.getError('date'),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              MyText.labelMedium(title, fontWeight: 600, muted: true),
            if (title != null)
              MySpacing.height(8),
            MyButton.outlined(
              onPressed: () {
                controller.pickDateTime(instanceIndex);
              },
              borderColor: colorScheme.primary,
              padding: MySpacing.xy(16, 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    LucideIcons.calendar_check,
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  MySpacing.width(10),
                  MyText.labelMedium(
                      controller.data[instanceIndex]!.selectedDate != null
                          ? "${dateFormatter.format(controller.data[instanceIndex]!.selectedDate!)}"
                          " ${timeFormatter.format(controller.data[instanceIndex]!.selectedDate!)}"
                          : hintText?? "Select Date & Time",
                      fontWeight: 600,
                      color: colorScheme.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void simpleToastMessage(SecretaryDateAddController controller, String text, Color color) {
    if (!mounted || !context.mounted) return; // makes sure the State is still alive

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      width: 300,
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: 1200),
      //animation: Tween<double>(begin: 0, end: 300).animate(controller.animationController),
      content: MyText.labelLarge(text, fontWeight: 600, color: contentTheme.onPrimary),
      backgroundColor: color,
    ));
  }
}
