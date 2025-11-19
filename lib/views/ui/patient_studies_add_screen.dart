import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
//import 'package:medicare/app_constant.dart';

import 'package:medicare/controller/ui/patient_studies_add_controller.dart';
import 'package:medicare/helpers/theme/app_themes.dart';

import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/helpers/widgets/my_form.dart';
import 'package:medicare/helpers/widgets/my_file_selector.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:blix_essentials/blix_essentials.dart';


class PatientStudiesAddScreen extends StatefulWidget {
  const PatientStudiesAddScreen({super.key});

  @override
  State<PatientStudiesAddScreen> createState() => _PatientStudiesAddScreenState();
}

class _PatientStudiesAddScreenState extends State<PatientStudiesAddScreen> with UIMixin {
  PatientStudiesAddController controller = Get.put(PatientStudiesAddController());

  int instanceIndex = -1;
  bool firstFrame = true;

  bool fistBuild = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.contextInstance.addInstance();

    controller.updatePatientInfo(instanceIndex).then((_) {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fistBuild) {
        fistBuild = false;
        controller.clearForm(instanceIndex);
      }
    });
  }

  @override
  void dispose() {
    controller.contextInstance.disposeInstance(instanceIndex);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'patient_studies_add_controller',
        builder: (controller) {
          double contentPadding = 20.0;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!firstFrame && controller.contextInstance.updateInstanceIndex != instanceIndex) return;
            controller.contextInstance.calculateContentSize(instanceIndex, "global", makeUpdate: false);
            controller.contextInstance.calculateContentSize(instanceIndex, "content", preventDuplicates: firstFrame);
            firstFrame = false;
          });

          final globalSize = controller.contextInstance.getContentSize(instanceIndex, "global");
          final contentWidth = controller.contextInstance.getContentWidth(instanceIndex, "content");

          final cardsWidth = contentWidth == null ? null : Utils.getColumnsWidth(
            contentWidth - (flexSpacing + contentPadding) * 2.0, minWidth: 250.0, spacing: 1.0, hardLimitMin: 3,
          );

          double? titlesSize(double? width, double extraPadding) {
            return width == null ? null : width + extraPadding;
          }

          return Column(
            key: controller.contextInstance.getContentKey(instanceIndex, "global"),
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
                        "Registro de Estudios Médicos",
                        fontSize: 18,
                        fontWeight: 600,
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: 'Médico'),
                          MyBreadcrumbItem(name: 'Paciente'),
                          MyBreadcrumbItem(name: 'Registrar Estudio', active: true),
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
                  child: MyForm(
                    addNewFormKey: controller.addNewFormKey,
                    disposeFormKey: controller.disposeFormKey,
                    child: Column(
                      key: controller.contextInstance.getContentKey(instanceIndex, "content"),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium("Registro de Estudios Médicos", fontWeight: 600, muted: true),
                        MySpacing.height(20),
                        commonTextField(
                          validator: controller.basicValidator.getValidation("description"),
                          teController: controller.basicValidator.getController("description"),
                          title: "Descripción",
                          hintText: "Descripción del estudio médico.",
                          //prefixIcon: Icon(Icons.numbers_sharp, size: 16),
                          height: 200,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          hasCounterText: true,
                          length: 1024,
                        ),
                        MySpacing.height(20),
                        RadioGroup<bool>(
                          groupValue: controller.data[instanceIndex]!.withImages,
                          onChanged: (value) => controller.onChangeWithImage(instanceIndex, value?? false),
                          child: Wrap(
                            spacing: 16,
                            children: [false, true].map((value) => InkWell(
                              onTap: () => controller.onChangeWithImage(instanceIndex, value?? false),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool>(
                                    value: value,
                                    activeColor: theme.colorScheme.primary,
                                    visualDensity: getCompactDensity,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  MySpacing.width(8),
                                  MyText.labelMedium(
                                    value ? "Con imágenes" : "Con pdf",
                                  ),
                                ],
                              ),
                            ),
                            ).toList(),
                          ),
                        ),
                        MySpacing.height(20),
                        if (controller.data[instanceIndex]!.withImages)
                          imageUploadSection(cardsWidth)
                        else
                          pdfUploadSection(),
                        MySpacing.height(20),
                        MyContainer(
                          onTap: () {
                            controller.onRegister(instanceIndex).then((validationError) {
                              if (validationError != null) {
                                if (!context.mounted) return;
                                simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                              }
                              else {
                                controller.manager.getPatientStudies(controller.data[instanceIndex]!.loggedPatient!.userNumber, AuthService.loggedUserNumber);
                                if (context.mounted) {
                                  simpleSnackBar(context, "Estudio registrado con éxito", contentTheme.success);// Color(0xFF35639D));
                                }
                                controller.goToList();
                              }
                            });
                          },
                          padding: MySpacing.xy(12, 8),
                          color: contentTheme.primary,
                          borderRadiusAll: 8,
                          child: MyText.labelMedium("Registrar", color: contentTheme.onPrimary, fontWeight: 600),
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

  Widget imageUploadSection(double? cardsWidth) {
    final providers = controller.data[instanceIndex]!.imageProviders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FileUploadWidget(
          instanceIndex: instanceIndex,
          hintText: "Arrastra aquí tus imágenes o",
          uploadButtonText: "busca en tus archivos",
          maxFileSize: FileSize(megabytes: 1),
          allowedFormats: MyFormats.image,
          allowMultiple: true,
          onFileSelected: (name, data, mime) => controller.loadImage(instanceIndex, name, data, mime),
          onError: (error) {
            if (error == "type" || error == "unsupported") {
              simpleSnackBar(context, "El archivo no es una imagen válida", contentTheme.danger);
            }
            else if (error == "size") {
              simpleSnackBar(context, "El archivo pesa más de 1MB", contentTheme.danger);
            }
            else if (error == "read") {
              simpleSnackBar(context, "El archivo no pudo leerse correctamente", contentTheme.danger);
            }
          },
          fileNameController: controller.data[instanceIndex]!.dropZoneTControllerImage,
        ),
        if (providers.isNotEmpty)
          MySpacing.height(20),
        Wrap(
          spacing: 1.0,
          runSpacing: 1.0,
          children: providers.mapIndexed<Widget>((i, e) =>
              postCard(cardsWidth, e, () {controller.deleteImage(instanceIndex, i);}),
          ).toList(),
        ),
      ],
    );
  }

  Widget postCard(double? width, ImageProvider image, void Function()? onDelete) {
    return Container(
      width: width,
      height: width == null ? null : width * 1.4,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: MyContainer(
          width: 30.0,
          height: 30.0,
          onTap: onDelete,
          shape: BoxShape.circle,
          color: Color.fromARGB(100, 0, 0, 0),
          margin: EdgeInsets.all(5.0),
          paddingAll: 0.0,
          child: Center(
            child: Icon(Icons.close, size: 20.0, color: Colors.white,),
          ),
        ),
      ),
    );
  }

  Widget pdfUploadSection() {
    return FileUploadWidget(
      instanceIndex: instanceIndex,
      hintText: "Arrastra aquí tu pdf o",
      uploadButtonText: "busca en tus archivos",
      maxFileSize: FileSize(megabytes: 8),
      allowMultiple: false,
      allowedFormats: [MyFormats.pdf],
      onFileSelected: (name, data, mime) => controller.loadPDF(instanceIndex, name, data, mime),
      onError: (error) {
        if (error == "type" || error == "unsupported") {
          simpleSnackBar(context, "El archivo no es un PDF válido", contentTheme.danger);
        }
        else if (error == "size") {
          simpleSnackBar(context, "El archivo pesa más de 8MB", contentTheme.danger);
        }
        else if (error == "read") {
          simpleSnackBar(context, "El archivo no pudo leerse correctamente", contentTheme.danger);
        }
      },
      fileNameController: controller.data[instanceIndex]!.dropZoneTControllerPdf,
      getFileSelectedMessage: (fileName) => "Archivo $fileName seleccionado",
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
        Container(
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
