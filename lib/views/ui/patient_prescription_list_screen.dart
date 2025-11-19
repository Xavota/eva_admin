import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/app_constant.dart';

import 'package:medicare/controller/ui/patient_prescription_list_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_string_utils.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_key_widget.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:blix_essentials/blix_essentials.dart';


class PatientPrescriptionListScreen extends StatefulWidget {
  const PatientPrescriptionListScreen({super.key});

  @override
  State<PatientPrescriptionListScreen> createState() => _PatientPrescriptionListScreenState();
}

class _PatientPrescriptionListScreenState extends State<PatientPrescriptionListScreen> with UIMixin {
  PatientPrescriptionListController controller = Get.put(PatientPrescriptionListController());

  int instanceIndex = -1;
  bool firstFrame = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.addInstance();
    controller.updatePrescriptions(instanceIndex);
  }

  @override
  void dispose() {
    controller.disposeInstance(instanceIndex);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'patient_prescription_list_controller',
        builder: (controller) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!firstFrame && controller.updateInstanceIndex != instanceIndex) return;
            firstFrame = false;
            controller.calculateContentWidth(instanceIndex, flexSpacing + 20);
          });

          final contentWidth = controller.getContentWidth(instanceIndex);

          Debug.log("controller.contentWidth: $contentWidth", overrideColor: Colors.purpleAccent);
          final cardsSpacing = 10.0;
          final cardsMinWidth = 400.0;
          int? cardsMaxCount = contentWidth == null ? null : contentWidth ~/ (cardsMinWidth + cardsSpacing);
          if (cardsMaxCount != null && ((cardsMaxCount + 1) * cardsMinWidth + cardsMaxCount * cardsSpacing) < contentWidth!) {
            cardsMaxCount += 1;
          }
          cardsMaxCount = cardsMaxCount == null ? null : math.max(math.min(cardsMaxCount, math.min(controller.prescriptions.length, 2)), 1);
          Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.purpleAccent);
          final totalSpacing = cardsMaxCount == null ? null : (cardsMaxCount - 1) * cardsSpacing;
          Debug.log("totalSpacing: $totalSpacing", overrideColor: Colors.purpleAccent);
          final availableCardSpace = totalSpacing == null ? null : contentWidth! - totalSpacing;
          Debug.log("availableCardSpace: $availableCardSpace", overrideColor: Colors.purpleAccent);
          final cardsWidth = availableCardSpace == null ? null : availableCardSpace / cardsMaxCount!;
          Debug.log("cardsWidth: $cardsWidth", overrideColor: Colors.purpleAccent);

          return Column(
            key: controller.getContentKey(instanceIndex),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Container(color: Colors.red, width: controller.contentWidth, height: 10.0,),
              ),*/
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Listado de Recetas",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Paciente'),
                        MyBreadcrumbItem(name: 'Lista Recetas', active: true),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Listado de Recetas", fontWeight: 600, muted: true),
                      MySpacing.height(10),
                      if (controller.prescriptions.isNotEmpty)
                        Wrap(
                          spacing: cardsSpacing * 0.99,
                          runSpacing: cardsSpacing,
                          children: controller.prescriptions
                              .mapIndexed((index, data) => prescriptionCard(
                            dateFormatter.format(data.creationDate),
                            data.plainText,
                            cardsWidth,
                                () {
                              controller.goDetailScreen(index);
                            },
                          )).toList(),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MyText.bodyMedium("No tienes recetas disponibles por el momento", fontWeight: 800, muted: true),
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

  Widget prescriptionCard(String date, String plainText, [
    double? width, void Function()? onTap,
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
            ],
          ),
          MySpacing.height(10.0),
          MyText.bodySmall(MyStringUtils.textCutout(plainText), fontWeight: 600),
          /*Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 60.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MyText.titleSmall("Receta: ", fontWeight: 800,),
                ),
              ),
              MySpacing.height(5.0),
              SizedBox(
                width: width == null ? null : width - 91.0, // 60 title + 5 spacing + 24 padding + 2 border
                child: MyText.bodySmall(controller.textCutout(plainText), fontWeight: 600),
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}
