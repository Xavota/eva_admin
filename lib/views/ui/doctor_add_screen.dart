//import 'package:medicare/app_constant.dart';
import 'package:medicare/controller/ui/doctor_add_controller.dart';
//import 'package:medicare/helpers/theme/app_themes.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_flex.dart';
import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/views/layout/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:blix_essentials/blix_essentials.dart';

class DoctorAddScreen extends StatefulWidget {
  const DoctorAddScreen({super.key});

  @override
  State<DoctorAddScreen> createState() => _DoctorAddScreenState();
}

class _DoctorAddScreenState extends State<DoctorAddScreen> with UIMixin {
  DoctorAddController controller = Get.put(DoctorAddController());

  TextEditingController userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_doctor_add_controller',
        builder: (controller) {
          final id = controller.currentUserId;
          controller.basicValidator.getController("userNumber")!.text =
          id == null ? "" : MyStringUtils.addZerosAtFront(id, lengthRequired: 4);
          Debug.log("Builder $id", overrideColor: Colors.pinkAccent);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Registrar Nuevo Doctor",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Admin'),
                        MyBreadcrumbItem(name: 'Añadir doctor', active: true),
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
                  child: Form(
                    key: controller.basicValidator.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium("Información básica", fontWeight: 600),
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
                                    teController: controller.basicValidator.getController("userNumber"),
                                    title: "Número de Usuario",
                                    hintText: "Error calculando número de usuario",
                                    prefixIcon: Icon(Icons.numbers_sharp, size: 16),
                                    numbered: true,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    validator: controller.basicValidator.getValidation("fullName"),
                                    teController: controller.basicValidator.getController("fullName"),
                                    title: "Nombre Completo",
                                    hintText: "Nombre completo",
                                    prefixIcon: Icon(LucideIcons.user_round, size: 16),
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    validator: controller.basicValidator.getValidation("speciality"),
                                    teController: controller.basicValidator.getController("speciality"),
                                    title: "Especialidad",
                                    hintText: "Especialidad",
                                    prefixIcon: Icon(LucideIcons.book_check, size: 16),
                                  ),
                                  /*MySpacing.height(20),
                                  commonTextField(title: "Education", hintText: "Education", prefixIcon: Icon(LucideIcons.graduation_cap, size: 16)),
                                  MySpacing.height(20),
                                  MyText.labelMedium("Department", fontWeight: 600, muted: true),
                                  MySpacing.height(8),
                                  DropdownButtonFormField<Department>(
                                      dropdownColor: contentTheme.background,
                                      isDense: true,
                                      style: MyTextStyle.bodySmall(),
                                      items: Department.values
                                          .map((category) => DropdownMenuItem<Department>(
                                        value: category,
                                        child: MyText.bodySmall(category.name.capitalize!),
                                      ))
                                          .toList(),
                                      icon: Icon(LucideIcons.chevron_down, size: 20),
                                      decoration: InputDecoration(
                                          hintText: "Select Department",
                                          hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          contentPadding: MySpacing.all(12),
                                          isCollapsed: true,
                                          isDense: true,
                                          prefixIcon: Icon(LucideIcons.circle_plus, size: 16),
                                          floatingLabelBehavior: FloatingLabelBehavior.never),
                                      onChanged: controller.basicValidator.onChanged<Object?>('Department')),
                                  MySpacing.height(20),
                                  commonTextField(title: "City", hintText: "City", prefixIcon: Icon(LucideIcons.map_pin_house, size: 16)),
                                  MySpacing.height(20),
                                  commonTextField(title: "State/Province", hintText: "State/Province", prefixIcon: Icon(LucideIcons.map, size: 16)),
                                  MySpacing.height(20),
                                  commonTextField(title: "Address", hintText: "Address", prefixIcon: Icon(LucideIcons.map_pin, size: 16)),*/
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
                                    numbered: true, length: 4,
                                  ),
                                  MySpacing.height(20),
                                  commonTextField(
                                    validator: controller.basicValidator.getValidation("professionalNumber"),
                                    teController: controller.basicValidator.getController("professionalNumber"),
                                    title: "Cédula Profesional",
                                    hintText: "Cédula profesional",
                                    prefixIcon: Icon(LucideIcons.shield_plus, size: 16),
                                    numbered: true, length: 8,
                                  ),
                                  /*MySpacing.height(20),
                                  MyText.bodyMedium("Gender", fontWeight: 600),
                                  MySpacing.height(20),
                                  Wrap(
                                    spacing: 16,
                                    children: Gender.values
                                        .map(
                                          (gender) => InkWell(
                                        onTap: () => controller.onChangeGender(gender),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Radio<Gender>(
                                              value: gender,
                                              activeColor: theme.colorScheme.primary,
                                              groupValue: controller.gender,
                                              onChanged: (value) => controller.onChangeGender(value),
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
                                  MySpacing.height(20),
                                  commonTextField(title: "Designation", hintText: "Designation", prefixIcon: Icon(LucideIcons.id_card, size: 16)),
                                  MySpacing.height(20),
                                  commonTextField(
                                      title: "Date Of Birth",
                                      hintText: "Select Date",
                                      prefixIcon: Icon(LucideIcons.cake, size: 16),
                                      onTap: controller.pickDate,
                                      teController: TextEditingController(text: controller.selectedDate != null ? dateFormatter.format(controller.selectedDate!) : "")),
                                  MySpacing.height(20),
                                  commonTextField(title: "Country", hintText: "Country", prefixIcon: Icon(LucideIcons.map_pin_house, size: 16)),
                                  MySpacing.height(20),
                                  commonTextField(title: "Postal Code", hintText: "Postal Code", prefixIcon: Icon(LucideIcons.mailbox, size: 16), numbered: true, length: 5),
                                  MySpacing.height(20),
                                  commonTextField(title: "Start Biography", hintText: "Start Biography", prefixIcon: Icon(LucideIcons.notepad_text, size: 16)),*/
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
                                  if (!context.mounted) return;
                                  if (validationError != null) {
                                    simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                                  }
                                  else {
                                    simpleSnackBar(context, "Doctor registrado con éxito", contentTheme.success);// Color(0xFF35639D));
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

  Widget commonTextField({String? title, String? hintText, String? initialString, bool? readOnly, String? Function(String?)? validator, Widget? prefixIcon, void Function()? onTap, TextEditingController? teController, bool numbered = false, int? length}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(title ?? "", fontWeight: 600, muted: true),
        MySpacing.height(8),
        TextFormField(
          validator: validator,
          readOnly: readOnly?? false,
          initialValue: initialString,
          onTap: onTap ?? () {},
          controller: teController,
          keyboardType: numbered ? TextInputType.phone : null,
          maxLength: length,
          inputFormatters: numbered ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))] : null,
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
