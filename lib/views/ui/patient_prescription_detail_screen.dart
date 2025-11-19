import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/controller/ui/patient_prescription_detail_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';


class PatientPrescriptionDetailScreen extends StatefulWidget {
  const PatientPrescriptionDetailScreen({super.key});

  @override
  State<PatientPrescriptionDetailScreen> createState() => _PatientPrescriptionDetailScreenState();
}

class _PatientPrescriptionDetailScreenState extends State<PatientPrescriptionDetailScreen> with UIMixin {
  PatientPrescriptionDetailController controller = Get.put(PatientPrescriptionDetailController());

  @override
  void initState() {
    super.initState();

    final String param = Get.parameters['index']!;
    final int index = int.parse(param);
    controller.updateInfo(index).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'patient_prescription_detail_controller',
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
                      "Vista de Receta",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Paciente'),
                        MyBreadcrumbItem(name: 'Vista Receta', active: true),
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
                      MyText.bodyMedium("Vista de Receta", fontWeight: 600, muted: true),
                      MySpacing.height(20),
                      if (controller.selectedPrescription != null)
                        MyText.bodyMedium(controller.selectedPrescription!.plainText)
                      else
                        MyText.bodySmall("No hay una receta seleccionada"),
                      MySpacing.height(20),
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
}
