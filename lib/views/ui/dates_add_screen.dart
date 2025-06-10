import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
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

import 'package:medicare/controller/ui/date_add_controller.dart';


import 'package:blix_essentials/blix_essentials.dart';


class DatesAddScreen extends StatefulWidget {
  const DatesAddScreen({super.key});

  @override
  State<DatesAddScreen> createState() => _DatesAddScreenState();
}

class _DatesAddScreenState extends State<DatesAddScreen> with UIMixin {
  DateAddController controller = Get.put(DateAddController());

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
        tag: 'admin_patient_add_controller',
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
                      "Agendar Cita",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Agendar Cita', active: true),
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
                                    title: "Fecha de la Cita",
                                    hintText: "Fecha y hora",
                                  ),
                                  /*commonTextField(
                                    title: "Fecha de la Cita",
                                    hintText: "Selecciona una fecha",
                                    validator: controller.basicValidator.getValidation("date"),
                                    teController: controller.basicValidator.getController("date"),
                                    prefixIcon: Icon(LucideIcons.cake, size: 16),
                                    onTap: controller.pickDate,
                                    readOnly: true,
                                  ),*/
                                ],
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(20),
                        MyText.labelMedium("Tratante", fontWeight: 600, muted: true),
                        MySpacing.height(15),
                        Wrap(
                          spacing: 16,
                          children: [
                            InkWell(
                              onTap: () => controller.onChangeTempPatient(false),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    activeColor: theme.colorScheme.primary,
                                    groupValue: controller.tempPatient,
                                    onChanged: (value) => controller.onChangeTempPatient(false),
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
                              onTap: () => controller.onChangeTempPatient(true),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    activeColor: theme.colorScheme.primary,
                                    groupValue: controller.tempPatient,
                                    onChanged: (value) => controller.onChangeTempPatient(true),
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
                        MySpacing.height(20),
                        MyFlex(
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.tempPatient)
                                    commonTextField(
                                      title: "Número de Teléfono", hintText: "Número de teléfono",
                                      validator: controller.basicValidator.getValidation("tempPhoneNumber"),
                                      teController: controller.basicValidator.getController("tempPhoneNumber"),
                                      prefixIcon: Icon(LucideIcons.phone, size: 16),
                                      integer: true, length: 10,
                                    ),
                                  if (controller.tempPatient)
                                    MySpacing.height(20),
                                  if (controller.tempPatient)
                                    MyText.labelMedium("Motivo de Consulta", fontWeight: 600, muted: true),
                                  if (controller.tempPatient)
                                    MySpacing.height(8),
                                  if (controller.tempPatient)
                                    consultationReasons(),
                                  if (!controller.tempPatient)
                                    selectPatientDropdown(),
                                ],
                              ),
                            ),
                            MyFlexItem(
                              sizes: 'lg-6 md-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.tempPatient)
                                    commonTextField(
                                      title: "Nombre Completo", hintText: "Nombre completo",
                                      validator: controller.basicValidator.getValidation("tempFullName"),
                                      teController: controller.basicValidator.getController("tempFullName"),
                                      prefixIcon: Icon(LucideIcons.user_round, size: 16),
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
                                controller.onRegister().then((validationError) {
                                  if (validationError != null) {
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, validationError, contentTheme.danger);
                                  }
                                  else {
                                    controller.manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber);
                                    controller.updatePatientsInfo();
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, "Cita agendada con éxito", contentTheme.success);
                                  }
                                });
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("Agendar", color: contentTheme.onPrimary, fontWeight: 600),
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

  Widget selectPatientDropdown(){
    return DropdownButtonFormField<PatientListModel>(
        dropdownColor: contentTheme.background,
        isDense: true,
        style: MyTextStyle.bodySmall(),
        items: controller.patients
            .map((patient) => DropdownMenuItem<PatientListModel>(
          value: patient,
          child: MyText.bodySmall("${patient.userNumber} ${patient.fullName}"),
        ))
            .toList(),
        icon: Icon(LucideIcons.chevron_down, size: 20),
        decoration: InputDecoration(
          hintText: "Elige Tratante",
          hintStyle: MyTextStyle.bodySmall(xMuted: true),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: MySpacing.all(12),
          isCollapsed: true,
          isDense: true,
          prefixIcon: Icon(LucideIcons.user, size: 16),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        onChanged: controller.onChangeSelectedPatient,
    );
    /*return Container(
      key: ValueKey(controller.selectedPatient?.fullName?? "NoPatient"),
      child: DropdownButtonFormField<PatientListModel>(
        dropdownColor: contentTheme.background,
        value: controller.selectedPatient,
        onChanged: controller.onChangeSelectedPatient,
        decoration: InputDecoration(
          hintText: "Elige Tratante",
          hintStyle: MyTextStyle.bodyMedium(),
          border: outlineInputBorder,
          disabledBorder: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          contentPadding: MySpacing.all(12),
          isCollapsed: true,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          errorText: controller.basicValidator.getError('userNumber'),
        ),
        items: controller.patients.map((patient) {
          return DropdownMenuItem<PatientListModel>(
            value: patient,
            child: MyText.labelMedium(
              "${patient.userNumber} ${patient.fullName}",
              fontWeight: 600,
            ),
          );
        }).toList(),
      ),
    );*/
  }

  Widget consultationReasons() {
    return Container(
      key: ValueKey(controller.consultationReasons.join()),
      child: Column(
        children: [
          InputDecorator(
            isEmpty: controller.consultationReasons.isEmpty,
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
              initialValue: controller.consultationReasons,
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
                controller.consultationReasons.isEmpty ? "" : "Motivos de consutla",
                style: MyTextStyle.bodySmall(xMuted: true),
              ),
              chipDisplay: MultiSelectChipDisplay.none(),
              onConfirm: (values) {
                controller.onConsultationChange(values);
              },
            ),
          ),
          Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: controller.consultationReasons.map<Widget>((item) {
              return InkWell(
                onTap: () {
                  Debug.log("Removing: ${item.name}", overrideColor: Colors.red);
                  controller.removeConsultation(item);
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

  Widget selectDateTime({String? title, String? hintText}) {
    Debug.log("controller.basicValidator.errors: ${controller.basicValidator.errors}");
    return Container(
      key: ValueKey(controller.selectedDate.toString()),
      child: InputDecorator(
        isEmpty: controller.selectedDate == null,
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
                controller.pickDateTime();
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
                      controller.selectedDate != null
                          ? "${dateFormatter.format(controller.selectedDate!)} ${timeFormatter.format(controller.selectedDate!)}"
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
}
