import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:file_picker/file_picker.dart';

import 'package:medicare/controller/ui/admin_premium_books_edit_controller.dart';

import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_flex.dart';
import 'package:medicare/helpers/widgets/my_form.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/my_file_selector.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:blix_essentials/blix_essentials.dart';

class AdminPremiumBooksEditScreen extends StatefulWidget {
  const AdminPremiumBooksEditScreen({super.key});

  @override
  State<AdminPremiumBooksEditScreen> createState() => _AdminPremiumBooksEditScreenState();
}

class _AdminPremiumBooksEditScreenState extends State<AdminPremiumBooksEditScreen> with UIMixin {
  AdminPremiumBooksEditController controller = Get.put(AdminPremiumBooksEditController());

  int instanceIndex = -1;
  bool firstFrame = true;

  bool fistBuild = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.contextInstance.addInstance();

    final String header = Get.parameters['header']!;
    final String subHeader = Get.parameters['subHeader']!;
    final String bookIndexStr = Get.parameters['bookIndex']!;
    final int? bookIndex = int.tryParse(bookIndexStr);
    controller.updateInfo(instanceIndex, header, subHeader, bookIndex?? -1);
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
        tag: 'admin_premium_books_edit_controller',
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

          final frontPageHeight = contentWidth == null ? 424.0 : math.min(contentWidth * 1.414, 650.0);
          final frontPageWidth = frontPageHeight / 1.414;

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
                        "Editar Libro",
                        fontSize: 18,
                        fontWeight: 600,
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: 'Admin'),
                          MyBreadcrumbItem(name: 'Contenido Premium', route: controller.getPreviousScreenRoute(instanceIndex)),
                          MyBreadcrumbItem(name: 'Ediar Libro', active: true),
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
                  paddingAll: contentPadding,
                  borderRadiusAll: 12,
                  child: MyForm(
                    //key: controller.basicValidator.formKey,
                    addNewFormKey: controller.addNewFormKey,
                    disposeFormKey: controller.disposeFormKey,
                    child: Column(
                      key: controller.contextInstance.getContentKey(instanceIndex, "content"),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium("Información Básica", fontWeight: 600),
                        MySpacing.height(20),
                        MyFlex(
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                              sizes: 'lg-12 md-12',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  commonTextField(
                                    title: "Título", hintText: "Título del libro",
                                    teController: controller.basicValidator.getController("title"),
                                    validator: controller.basicValidator.getValidation("title"),
                                    prefixIcon: Icon(Icons.title, size: 16),
                                    length: 256,
                                  ),
                                  MySpacing.height(20.0),
                                  FileUploadWidget(
                                    instanceIndex: instanceIndex,
                                    hintText: "Arrastra aquí tu foto de portada",
                                    uploadButtonText: "busca en tus archivos",
                                    maxFileSize: FileSize(megabytes: 5),
                                    allowMultiple: false,
                                    allowedFormats: MyFormats.image,
                                    onFileSelected: (name, data, mime) => controller.loadFrontPage(instanceIndex, name, data, mime),
                                    onError: (error) {
                                      if (error == "type" || error == "unsupported") {
                                        simpleSnackBar(context, "El archivo no es una imagen válida", contentTheme.danger);
                                      }
                                      else if (error == "size") {
                                        simpleSnackBar(context, "El archivo pesa más de 5MB", contentTheme.danger);
                                      }
                                      else if (error == "read") {
                                        simpleSnackBar(context, "El archivo no pudo leerse correctamente", contentTheme.danger);
                                      }
                                    },
                                    fileNameController: controller.data[instanceIndex]!.dropZoneTControllerFrontPage,
                                    getFileSelectedMessage: (fileName) => 'Imagen "$fileName" seleccionado',
                                  ),
                                  if (controller.data[instanceIndex]!.frontPageProvider != null)
                                    MySpacing.height(20.0),
                                  if (controller.data[instanceIndex]!.frontPageProvider != null)
                                    Container(
                                      width: frontPageWidth,
                                      height: frontPageHeight,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: controller.data[instanceIndex]!.frontPageProvider!,
                                          fit: BoxFit.cover
                                        ),
                                      ),
                                    ),
                                  MySpacing.height(20.0),
                                  FileUploadWidget(
                                    instanceIndex: instanceIndex,
                                    hintText: "Arrastra aquí tu libro",
                                    uploadButtonText: "busca en tus archivos",
                                    maxFileSize: FileSize(megabytes: 128),
                                    allowMultiple: false,
                                    allowedFormats: [MyFormats.pdf],
                                    onFileSelected: (name, data, mime) => controller.loadBook(instanceIndex, name, data, mime),
                                    onError: (error) {
                                      if (error == "type" || error == "unsupported") {
                                        simpleSnackBar(context, "El archivo no es un PDF válido", contentTheme.danger);
                                      }
                                      else if (error == "size") {
                                        simpleSnackBar(context, "El archivo pesa más de 128MB", contentTheme.danger);
                                      }
                                      else if (error == "read") {
                                        simpleSnackBar(context, "El archivo no pudo leerse correctamente", contentTheme.danger);
                                      }
                                    },
                                    fileNameController: controller.data[instanceIndex]!.dropZoneTControllerBook,
                                    getFileSelectedMessage: (fileName) => 'Archivo "$fileName" seleccionado',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MyContainer(
                              onTap: () {
                                controller.onEdit(instanceIndex).then((validationError) {
                                  if (validationError != null) {
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                                  }
                                  else {
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, "Libro editado con éxito", contentTheme.success);// Color(0xFF35639D));
                                  }
                                });
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("Editar", color: contentTheme.onPrimary, fontWeight: 600),
                            ),
                          ],
                        ),
                        MySpacing.height(20)
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

  Widget commonTextField({String? title, String? hintText, bool? readOnly,
    String? Function(String?)? validator, Widget? prefixIcon,
    void Function()? onTap, TextEditingController? teController,
    bool numbered = false, int? length
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(title ?? "", fontWeight: 600, muted: true),
        MySpacing.height(8),
        TextFormField(
          validator: validator,
          readOnly: readOnly?? false,
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
