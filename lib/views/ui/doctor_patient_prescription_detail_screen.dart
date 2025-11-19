import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/controller/ui/doctor_patient_prescription_detail_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';


class DoctorPatientPrescriptionDetailScreen extends StatefulWidget {
  const DoctorPatientPrescriptionDetailScreen({super.key});

  @override
  State<DoctorPatientPrescriptionDetailScreen> createState() => _DoctorPatientPrescriptionDetailScreenState();
}

class _DoctorPatientPrescriptionDetailScreenState extends State<DoctorPatientPrescriptionDetailScreen> with UIMixin {
  DoctorPatientPrescriptionDetailController controller = Get.put(DoctorPatientPrescriptionDetailController());

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
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'doctor_patient_prescription_detail_controller',
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
                        MyBreadcrumbItem(name: 'Médico'),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText.bodyMedium("Vista de Receta", fontWeight: 600, muted: true),
                          MyContainer(
                            onTap: controller.goEditScreen,
                            padding: MySpacing.xy(12, 8),
                            borderRadiusAll: 8,
                            color: contentTheme.primary,
                            child: MyText.labelSmall("Editar Receta", fontWeight: 600, color: contentTheme.onPrimary),
                          )
                        ],
                      ),
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
