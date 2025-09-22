import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
//import 'package:medicare/app_constant.dart';

import 'package:medicare/controller/ui/doctor_patient_prescription_edit_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
//import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/helpers/widgets/my_form.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientPrescriptionEditScreen extends StatefulWidget {
  const DoctorPatientPrescriptionEditScreen({super.key});

  @override
  State<DoctorPatientPrescriptionEditScreen> createState() => _DoctorPatientPrescriptionEditScreenState();
}

class _DoctorPatientPrescriptionEditScreenState extends State<DoctorPatientPrescriptionEditScreen> with UIMixin {
  DoctorPatientPrescriptionEditController controller = Get.put(DoctorPatientPrescriptionEditController());

  bool fistBuild = true;

  @override
  void initState() {
    super.initState();

    final String param1 = Get.parameters['patientIndex']!;
    final int patientIndex = int.parse(param1);
    final String param2 = Get.parameters['index']!;
    final int index = int.parse(param2);
    controller.updateInfo(patientIndex, index).then((_) {
      setState(() {});
    });

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
        tag: 'doctor_patient_prescription_edit_controller',
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
                      "Edición de Receta",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Tratante'),
                        MyBreadcrumbItem(name: 'Edición Receta', active: true),
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
                        MyText.bodyMedium("Edición de Receta", fontWeight: 600, muted: true),
                        MySpacing.height(20),
                        commonTextField(
                          validator: controller.basicValidator.getValidation("plainText"),
                          teController: controller.basicValidator.getController("plainText"),
                          title: "Contenido",
                          hintText: "Contenido de la receta médica.",
                          //prefixIcon: Icon(Icons.numbers_sharp, size: 16),
                          height: 800,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          hasCounterText: true,
                          length: 4096,
                        ),
                        MySpacing.height(20),
                        MyContainer(
                          onTap: () {
                            controller.onEdit().then((validationError) {
                              if (validationError != null) {
                                if (!context.mounted) return;
                                simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                              }
                              else {
                                controller.manager.getPatientPrescriptions(controller.selectedPatient!.userNumber, AuthService.loggedUserNumber);
                                if (!context.mounted) return;
                                simpleSnackBar(context, "Receta editada con éxito", contentTheme.success);// Color(0xFF35639D));
                              }
                            });
                          },
                          padding: MySpacing.xy(12, 8),
                          color: contentTheme.primary,
                          borderRadiusAll: 8,
                          child: MyText.labelMedium("Guardar", color: contentTheme.onPrimary, fontWeight: 600),
                        ),
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
    String? title, String? hintText, bool readOnly = false, double height = 150.0,
    String? Function(String?)? validator, Widget? prefixIcon,
    void Function()? onTap, TextEditingController? teController,
    bool integer = false, bool floatingPoint = false, int? length,
    int? maxLines = 1, bool hasCounterText = false, bool expands = false,
    TextAlignVertical? textAlignVertical,
    void Function(String)? onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(title ?? "", fontWeight: 600, muted: true),
        MySpacing.height(8),
        SizedBox(
          height: height,
          //padding: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
          /*decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),*/
          child: TextFormField(
            controller: teController,
            maxLines: maxLines,
            expands: expands,
            textAlignVertical: textAlignVertical,
            validator: validator,
            readOnly: readOnly,
            onTap: onTap ?? () {},
            keyboardType: integer ? TextInputType.phone : null,
            maxLength: length != null ? (length + (!integer && floatingPoint ? 3 : 0)) : null,
            inputFormatters: integer ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
                : (floatingPoint ? <TextInputFormatter>[FloatingPointTextInputFormatter(maxDigitsBeforeDecimal: length, maxDigitsAfterDecimal: 2)] : null),
            style: MyTextStyle.bodySmall(),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              //border: InputBorder.none,
              hintText: hintText,
              //counterText: hasCounterText ? '${teController?.text.length}/$length' : "", // Character counter
              hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
              isCollapsed: true,
              isDense: true,
              prefixIcon: prefixIcon,
              contentPadding: MySpacing.all(16),
            ),
            buildCounter: !hasCounterText ? null :
            (BuildContext context, {
              required int currentLength,
              required bool isFocused,
              required int? maxLength,
            }) {
              return Text(
                '$currentLength/$maxLength',
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
              );
            },
            onChanged: onChange,
          ),
        ),
      ],
    );
  }
}
