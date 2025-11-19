import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:file_picker/file_picker.dart';

import 'package:medicare/controller/ui/admin_premium_posts_edit_controller.dart';

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

class AdminPremiumPostsEditScreen extends StatefulWidget {
  const AdminPremiumPostsEditScreen({super.key});

  @override
  State<AdminPremiumPostsEditScreen> createState() => _AdminPremiumPostsEditScreenState();
}

class _AdminPremiumPostsEditScreenState extends State<AdminPremiumPostsEditScreen> with UIMixin {
  AdminPremiumPostsEditController controller = Get.put(AdminPremiumPostsEditController());

  int instanceIndex = -1;
  bool firstFrame = true;

  bool fistBuild = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.contextInstance.addInstance();

    final String header = Get.parameters['header']!;
    final String subHeader = Get.parameters['subHeader']!;
    final String postIndexStr = Get.parameters['postIndex']!;
    final int? postIndex = int.tryParse(postIndexStr);
    controller.updateInfo(instanceIndex, header, subHeader, postIndex?? -1);
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
        tag: 'admin_premium_posts_add_controller',
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
                        "Editar publicación",
                        fontSize: 18,
                        fontWeight: 600,
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: 'Admin'),
                          MyBreadcrumbItem(name: 'Contenido Premium', route: controller.getPreviousScreenRoute(instanceIndex)),
                          MyBreadcrumbItem(name: 'Editar publicación', active: true),
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
                                  Theme(
                                    data: ThemeData(colorScheme: colorScheme),
                                    child: CheckboxListTile(
                                      value: controller.data[instanceIndex]!.free,
                                      onChanged: (value) => controller.onFreeCheckboxChange(instanceIndex, value?? false),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      contentPadding: MySpacing.x(0),
                                      visualDensity: VisualDensity.compact,
                                      dense: true,
                                      title: MyText.bodySmall("Contenido Gratis", fontWeight: 600),
                                    ),
                                  ),
                                  MySpacing.height(20.0),
                                  commonTextField(
                                    title: "Título", hintText: "Título de la publicación",
                                    teController: controller.basicValidator.getController("title"),
                                    validator: controller.basicValidator.getValidation("title"),
                                    prefixIcon: Icon(Icons.title, size: 16),
                                    length: 256,
                                  ),
                                  MySpacing.height(20.0),
                                  commonTextField(
                                    title: "Descripción", hintText: "Descripción de la publicación",
                                    teController: controller.basicValidator.getController("description"),
                                    validator: controller.basicValidator.getValidation("description"),
                                    prefixIcon: Icon(LucideIcons.rss, size: 16),
                                    length: 4096,
                                  ),
                                  MySpacing.height(20.0),
                                  FileUploadWidget(
                                    instanceIndex: instanceIndex,
                                    hintText: "Arrastra aquí tus imágenes o",
                                    uploadButtonText: "busca en tus archivos",
                                    maxFileSize: FileSize(megabytes: 1),
                                    allowedFormats: MyFormats.image,
                                    allowMultiple: true,
                                    onFileSelected: (name, data, mime) => controller.loadImage(instanceIndex, name, data, mime),
                                    onError: (error) {
                                      if (error == "type") {
                                        simpleSnackBar(context, "El archivo no es una imagen válida", contentTheme.danger);
                                      }
                                      else if (error == "size") {
                                        simpleSnackBar(context, "El archivo pesa más de 1MB", contentTheme.danger);
                                      }
                                    },
                                  ),
                                  MySpacing.height(20),
                                  Wrap(
                                    spacing: 1.0,
                                    runSpacing: 1.0,
                                    children: controller.data[instanceIndex]!.imageProviders.mapIndexed<Widget>((i, e) =>
                                        postCard(cardsWidth, e, () {controller.deleteImage(instanceIndex, i);}),
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
                                controller.onEdit(instanceIndex).then((validationError) {
                                  if (validationError != null) {
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                                  }
                                  else {
                                    if (!context.mounted) return;
                                    simpleSnackBar(context, "Publicación editada con éxito", contentTheme.success);// Color(0xFF35639D));
                                    //controller.goListContent(instanceIndex);
                                  }
                                });
                              },
                              padding: MySpacing.xy(12, 8),
                              color: contentTheme.primary,
                              borderRadiusAll: 8,
                              child: MyText.labelMedium("Guardar cambios", color: contentTheme.onPrimary, fontWeight: 600),
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
}
