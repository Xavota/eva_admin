import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';


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

import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/controller/ui/doctor_patient_add_controller.dart';


import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientAddScreen extends StatefulWidget {
  const DoctorPatientAddScreen({super.key});

  @override
  State<DoctorPatientAddScreen> createState() => _DoctorPatientAddScreenState();
}

class _DoctorPatientAddScreenState extends State<DoctorPatientAddScreen> with UIMixin {
  DoctorPatientAddController controller = Get.put(DoctorPatientAddController());

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
                      "Registrar Tratante",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Registrar Tratante', active: true),
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
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Peso (kg)", hintText: "Su peso en kilogramos",
                                    validator: controller.basicValidator.getValidation("weight"),
                                    teController: controller.basicValidator.getController("weight"),
                                    prefixIcon: Icon(LucideIcons.person_standing, size: 16),
                                    floatingPoint: true, length: 3,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Altura (m)", hintText: "Su altura en metros",
                                    validator: controller.basicValidator.getValidation("height"),
                                    teController: controller.basicValidator.getController("height"),
                                    prefixIcon: Icon(LucideIcons.person_standing, size: 16),
                                    floatingPoint: true, length: 3,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Ocupación", hintText: "Ocupación",
                                    validator: controller.basicValidator.getValidation("job"),
                                    teController: controller.basicValidator.getController("job"),
                                    prefixIcon: Icon(LucideIcons.person_standing, size: 16),
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Número de Teléfono", hintText: "Número de teléfono",
                                    validator: controller.basicValidator.getValidation("phoneNumber"),
                                    teController: controller.basicValidator.getController("phoneNumber"),
                                    prefixIcon: Icon(LucideIcons.person_standing, size: 16),
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
                                  commonTextField(
                                    validator: controller.basicValidator.getValidation("pin"),
                                    teController: controller.basicValidator.getController("pin"),
                                    title: "NIP", hintText: "NIP",
                                    prefixIcon: Icon(LucideIcons.lock, size: 16),
                                    integer: true, length: 4,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Edad", hintText: "Edad",
                                    validator: controller.basicValidator.getValidation("age"),
                                    teController: controller.basicValidator.getController("age"),
                                    prefixIcon: Icon(LucideIcons.person_standing, size: 16),
                                    integer: true, length: 3,
                                  ),
                                  MySpacing.height(20),
                                  MyText.labelMedium("Sexo", fontWeight: 600, muted: true),
                                  MySpacing.height(15),
                                  Wrap(
                                    spacing: 16,
                                    children: Sex.values.map((gender) => InkWell(
                                        onTap: () => controller.onChangeSex(gender),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Radio<Sex>(
                                              value: gender,
                                              activeColor: theme.colorScheme.primary,
                                              groupValue: controller.sex,
                                              onChanged: (value) => controller.onChangeSex(value),
                                              visualDensity: getCompactDensity,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            MySpacing.width(8),
                                            MyText.labelMedium(
                                              gender.name.capitalize!,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).toList(),
                                  ),
                                  MySpacing.height(30),
                                  commonTextField(
                                    title: "Cintura (cm)", hintText: "Medida de su cintura",
                                    validator: controller.basicValidator.getValidation("waist"),
                                    teController: controller.basicValidator.getController("waist"),
                                    prefixIcon: Icon(LucideIcons.person_standing, size: 16),
                                    floatingPoint: true, length: 3,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    title: "Fecha de Nacimiento",
                                    hintText: "Selecciona una fecha",
                                    validator: controller.basicValidator.getValidation("birthDate"),
                                    teController: controller.basicValidator.getController("birthDate"),
                                    prefixIcon: Icon(LucideIcons.cake, size: 16),
                                    onTap: controller.pickDate,
                                    readOnly: true,
                                  ),
                                  MySpacing.height(20),
                                  MyText.labelMedium("Motivo de Consulta", fontWeight: 600, muted: true),
                                  MySpacing.height(8),
                                  Container(
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
                                            errorText: controller.basicValidator.getError('consultation'),
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
                                  ),
                                  /*MySpacing.height(8),
                                  FormField<List<ConsultationReason>>(
                                    //initialValue: controller.basicValidator.getValue<List<ConsultationReason>>("consultation") ?? [],
                                    validator: (value) {
                                      return controller.basicValidator.getError("consultation");
                                    },
                                    builder: (FormFieldState<List<ConsultationReason>> fieldState) {
                                      return InputDecorator(
                                        isEmpty: fieldState.value == null || fieldState.value!.isEmpty,
                                        decoration: InputDecoration(
                                          hintText: "A qué viene a consulta",
                                          hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: contentTheme.background,
                                          contentPadding: MySpacing.all(2),
                                          isCollapsed: true,
                                          isDense: true,
                                          prefixIcon: Icon(LucideIcons.heart_pulse, size: 16),
                                          floatingLabelBehavior: FloatingLabelBehavior.never,
                                          errorText: fieldState.errorText,
                                        ),
                                        child: MultiSelectDialogField<ConsultationReason>(
                                          items: ConsultationReason.values
                                              .map((category) => MultiSelectItem<ConsultationReason>(
                                            category,
                                            category.name,
                                          ))
                                              .toList(),
                                          searchable: true,
                                          dialogHeight: 400,
                                          selectedColor: Theme.of(context).colorScheme.primary,
                                          buttonIcon: Icon(LucideIcons.chevron_down, size: 20),
                                          buttonText: Text(
                                            fieldState.value == null || fieldState.value!.isEmpty
                                                ? ""
                                                : "Motivos de consulta",
                                            style: MyTextStyle.bodySmall(),
                                          ),
                                          decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                                          chipDisplay: null, // <-- remove chips from field
                                          onConfirm: (values) {
                                            fieldState.didChange(values);
                                            controller.basicValidator.onChanged<List<ConsultationReason>?>('consultation')(values);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  MySpacing.height(8),
                                  DropdownButtonFormField<ConsultationReason>(
                                    dropdownColor: contentTheme.background,
                                    isDense: true,
                                    style: MyTextStyle.bodySmall(),
                                    items: ConsultationReason.values
                                        .map((category) => DropdownMenuItem<ConsultationReason>(
                                      value: category,
                                      child: MyText.labelMedium(category.name),
                                    ))
                                        .toList(),
                                    icon: Icon(LucideIcons.chevron_down, size: 20),
                                    decoration: InputDecoration(
                                      hintText: "A qué viene a consulta",
                                      hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: MySpacing.all(12),
                                      isCollapsed: true,
                                      isDense: true,
                                      prefixIcon: Icon(LucideIcons.heart_pulse, size: 16),
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      errorText: controller.basicValidator.getError("consultation"),
                                    ),
                                    onChanged: controller.basicValidator.onChanged<ConsultationReason?>('consultation'),
                                  ),*/
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
                                    simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                                  }
                                  else {
                                    controller.calculateUserID();
                                    controller.manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber);
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, "Tratante registrado con éxito", contentTheme.success);// Color(0xFF35639D));
                                  }
                                });
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("Registrar", color: contentTheme.onPrimary, fontWeight: 600),
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
