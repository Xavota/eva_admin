import 'dart:math' as math;

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:medicare/app_constant.dart';

import 'package:medicare/controller/ui/doctor_patient_studies_list_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_string_utils.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientStudiesListScreen extends StatefulWidget {
  const DoctorPatientStudiesListScreen({super.key});

  @override
  State<DoctorPatientStudiesListScreen> createState() => _DoctorPatientStudiesListScreenState();
}

class _DoctorPatientStudiesListScreenState extends State<DoctorPatientStudiesListScreen> with UIMixin {
  DoctorPatientStudiesListController controller = Get.put(DoctorPatientStudiesListController());

  int instanceIndex = -1;
  bool firstFrame = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.contextInstance.addInstance();

    final String param = Get.parameters['patientIndex']!;
    final int index = int.parse(param);
    controller.updatePatientInfo(instanceIndex, index).then((_) {
      controller.updateStudies(instanceIndex, true);
      setState(() {});
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
        tag: 'doctor_patient_studies_list_controller',
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

          Debug.log("controller.contentWidth: $contentWidth", overrideColor: Colors.purpleAccent);
          final cardsSpacing = 10.0;
          final cardsMinWidth = 400.0;
          int? cardsMaxCount = contentWidth == null ? null : contentWidth ~/ (cardsMinWidth + cardsSpacing);
          if (cardsMaxCount != null && ((cardsMaxCount + 1) * cardsMinWidth + cardsMaxCount * cardsSpacing) < contentWidth!) {
            cardsMaxCount += 1;
          }
          cardsMaxCount = cardsMaxCount == null ? null : math.max(math.min(cardsMaxCount, math.min(controller.data[instanceIndex]!.studies.length, 2)), 1);
          Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.purpleAccent);
          final totalSpacing = cardsMaxCount == null ? null : (cardsMaxCount - 1) * cardsSpacing;
          Debug.log("totalSpacing: $totalSpacing", overrideColor: Colors.purpleAccent);
          final availableCardSpace = totalSpacing == null ? null : contentWidth! - totalSpacing;
          Debug.log("availableCardSpace: $availableCardSpace", overrideColor: Colors.purpleAccent);
          final cardsWidth = availableCardSpace == null ? null : availableCardSpace / cardsMaxCount!;
          Debug.log("cardsWidth: $cardsWidth", overrideColor: Colors.purpleAccent);

          double? titlesSize(double? width, double extraPadding) {
            return width == null ? null : width + extraPadding;
          }

          return Column(
            key: controller.contextInstance.getContentKey(instanceIndex, "global"),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Container(color: Colors.red, width: controller.contentWidth, height: 10.0,),
              ),*/
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
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: MyText.titleMedium(
                          "Listado de Estudios Médicos",
                          fontSize: 18,
                          fontWeight: 600,
                        ),
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: 'Médico'),
                          MyBreadcrumbItem(name: 'Paciente'),
                          MyBreadcrumbItem(name: 'Lista Estudios', active: true),
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
                  child: Column(
                    key: controller.contextInstance.getContentKey(instanceIndex, "content"),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: titlesSize(
                          contentWidth,
                          0.0,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MyText.bodyMedium("Listado de Estudios Médicos", fontWeight: 600, muted: true),
                            ),
                            MyContainer(
                              onTap: () => controller.goAddScreen(instanceIndex),
                              padding: MySpacing.xy(12, 8),
                              borderRadiusAll: 8,
                              color: contentTheme.primary,
                              child: MyText.labelSmall("Añadir Nuevo Estudio", fontWeight: 600, color: contentTheme.onPrimary),
                            )
                          ],
                        ),
                      ),
                      MySpacing.height(10),
                      if (controller.data[instanceIndex]!.studies.isNotEmpty)
                        Wrap(
                          spacing: cardsSpacing * 0.99,
                          runSpacing: cardsSpacing,
                          children: controller.data[instanceIndex]!.studies
                              .mapIndexed((index, data) => studyCard(
                            dateFormatter.format(data.creationDate),
                            data.description,
                            cardsWidth,
                            () {
                              controller.goDetailScreen(instanceIndex, index);
                            },
                            () {
                              controller.askToDeleteStudy(
                                context: context,
                                title: Padding(
                                  padding: MySpacing.all(16),
                                  child: MyText.labelLarge('Confirmación de Borrado', fontWeight: 600),
                                ),
                                child: Padding(
                                  padding: MySpacing.all(16),
                                  child: MyText.bodySmall(
                                    "¿Está seguro de que desea borrar este estudio médico?"
                                        "\nEsta acción no se puede deshacer.",
                                    fontWeight: 600,
                                  ),
                                ),
                                buttons: Padding(
                                  padding: MySpacing.all(10),
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
                                        onPressed: () async {
                                          await controller.confirmDeleteStudy(instanceIndex, index);
                                          controller.updateStudies(instanceIndex, false);
                                          Get.back();
                                        },
                                        elevation: 0,
                                        borderRadiusAll: 8,
                                        padding: MySpacing.xy(20, 16),
                                        backgroundColor: colorScheme.primary,
                                        child: MyText.labelMedium(
                                          "Borrar",
                                          fontWeight: 600,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )).toList(),
                        ),
                      if (controller.data[instanceIndex]!.studies.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MyText.bodyMedium("No hay estudios médicos registrados", fontWeight: 800, muted: true),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget studyCard(String date, String description, [
    double? width, void Function()? onTap, void Function()? onDelete
  ]) {
    return MyContainer(
      onTap: onTap,
      width: width,
      bordered: true,
      border: Border.all(
        color: Colors.black54,
        width: 1.0,
      ),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      paddingAll: 12.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText.titleSmall("Fecha: ", fontWeight: 800,),
                  MySpacing.width(5.0),
                  MyText.bodySmall(date, fontWeight: 600),
                ],
              ),
              MyContainer(
                onTap: onDelete,
                paddingAll: 8,
                color: contentTheme.secondary.withAlpha(32),
                child: Icon(Icons.delete, size: 16),
              ),
            ],
          ),
          MySpacing.height(10.0),
          MyText.bodySmall(
            MyStringUtils.textCutout(description, maxChars: 128, singleLine: true),
            fontWeight: 600,
          ),
        ],
      ),
    );
  }
}
