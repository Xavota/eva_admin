import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:medicare/controller/ui/doctor_patient_info_list_controller.dart';

import 'package:medicare/helpers/theme/app_themes.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/utils.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:medicare/model/patient_list_model.dart';

import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientInfoListScreen extends StatefulWidget {
  const DoctorPatientInfoListScreen({super.key});

  @override
  State<DoctorPatientInfoListScreen> createState() => _DoctorPatientInfoListScreenState();
}

class _DoctorPatientInfoListScreenState extends State<DoctorPatientInfoListScreen> with UIMixin {
  DoctorPatientInfoListController controller = Get.put(DoctorPatientInfoListController());

  @override
  void initState() {
    super.initState();
    controller.updatePatients();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tableFlexWidth = (1541 - 888 - (1920 - screenWidth));

    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'doctor_patient_info_list_controller',
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
                      "Listado de Pacientes",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Lista Pacientes', active: true),
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
                          MyText.bodyMedium("Listado de Pacientes", fontWeight: 600, muted: true),
                          MyContainer(
                            onTap: controller.addPatient,
                            padding: MySpacing.xy(12, 8),
                            borderRadiusAll: 8,
                            color: contentTheme.primary,
                            child: MyText.labelSmall("Registrar Paciente", fontWeight: 600, color: contentTheme.onPrimary),
                          )
                        ],
                      ),
                      RadioGroup(
                        groupValue: controller.activeFilter,
                        onChanged: (value) => controller.setActiveFilter(value),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => controller.setActiveFilter(null),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool?>(
                                    value: null,
                                    activeColor: theme.colorScheme.primary,
                                    visualDensity: getCompactDensity,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  MySpacing.width(8),
                                  MyText.labelMedium(
                                    "Todos",
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.0,),
                            InkWell(
                              onTap: () => controller.setActiveFilter(true),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool?>(
                                    value: true,
                                    activeColor: theme.colorScheme.primary,
                                    visualDensity: getCompactDensity,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  MySpacing.width(8),
                                  MyText.labelMedium(
                                    "Activos",
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.0,),
                            InkWell(
                              onTap: () => controller.setActiveFilter(false),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool?>(
                                    value: false,
                                    activeColor: theme.colorScheme.primary,
                                    visualDensity: getCompactDensity,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  MySpacing.width(8),
                                  MyText.labelMedium(
                                    "Archivados",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      MySpacing.height(20),
                      if (controller.patients.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              sortAscending: true,
                              columnSpacing: 30,
                              horizontalMargin: 15.0,
                              onSelectAll: (_) => {},
                              headingRowColor: WidgetStatePropertyAll(contentTheme.primary.withAlpha(40)),
                              dataRowMaxHeight: 60,
                              showBottomBorder: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              border: TableBorder.all(
                                  borderRadius: BorderRadius.circular(12), style: BorderStyle.solid, width: .4, color: contentTheme.secondary),
                              columns: [
                                DataColumn(label: MyText.labelMedium('Usuario', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Nombre', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Edad', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Sexo', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Peso', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Altura', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Cintura', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Ocupación', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Nacimiento', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Teléfono', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Acciones', color: contentTheme.primary)),
                              ],
                              rows: controller.patients
                                  .mapIndexed((index, data) => DataRow(
                                cells: [
                                  /*DataCell(SizedBox(
                                          width: 200,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              MyContainer.rounded(
                                                paddingAll: 0,
                                                height: 32,
                                                width: 32,
                                                child: Image.asset(Images.avatars[index % Images.avatars.length], fit: BoxFit.cover),
                                              ),
                                              MySpacing.width(16),
                                              MyText.bodySmall(data.name),
                                            ],
                                          ),
                                        )),*/
                                  DataCell(SizedBox(width: 47, child: MyText.bodySmall(data.userNumber))),
                                  DataCell(SizedBox(width: math.max(tableFlexWidth * 0.625, 200), child: MyText.bodySmall(data.fullName))),
                                  DataCell(SizedBox(width: 35, child: MyText.bodySmall(data.age.toString()))),
                                  DataCell(SizedBox(width: 35, child: MyText.bodySmall(data.sex.name))),
                                  DataCell(SizedBox(width: 50, child: MyText.bodySmall(data.weight.toString()))),
                                  DataCell(SizedBox(width: 50, child: MyText.bodySmall(data.height.toString()))),
                                  DataCell(SizedBox(width: 50, child: MyText.bodySmall(data.waist.toString()))),
                                  DataCell(SizedBox(width: math.max(tableFlexWidth * 0.375, 120), child: MyText.bodySmall(data.job))),
                                  DataCell(SizedBox(width: 75, child: MyText.bodySmall(Utils.getDateStringFromDateTime(data.birthDate)))),
                                  DataCell(SizedBox(width: 80, child: MyText.bodySmall(data.phoneNumber))),
                                  DataCell(Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /*MyContainer(
                                        onTap: () => controller.changePatientStatus(index, !data.status).then((response) {
                                          if (context.mounted) {
                                            if (response) {
                                              simpleSnackBar(context, "Paciente ${(data.status ? "" : "des")}archivado con éxito", contentTheme.success);// Color(0XFFAA236E));
                                            }
                                            else {
                                              simpleSnackBar(context, "Hubo un error en el servidor, intenta de nuevo más tarde", contentTheme.danger);// Color(0XFFAA236E));
                                            }
                                          }
                                          if (response) {
                                            setState(() {});
                                          }
                                        }),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        tooltip: MyContainer.shadow(
                                          borderRadius: BorderRadius.circular(5.0),
                                          color: Color.fromARGB(255, 245, 245, 245),
                                          paddingAll: 10,
                                          child: MyText.labelMedium("${(data.status ? "A" : "Desa")}rchivar",),
                                        ),
                                        child: Icon(data.status ? LucideIcons.archive : LucideIcons.archive_restore, size: 16),
                                      ),
                                      MySpacing.width(20),*/
                                      MyContainer(
                                        onTap: () => controller.goDetailScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        tooltip: MyContainer.shadow(
                                          borderRadius: BorderRadius.circular(5.0),
                                          color: Color.fromARGB(255, 245, 245, 245),
                                          paddingAll: 10,
                                          child: MyText.labelMedium("Detalles",),
                                        ),
                                        child: Icon(LucideIcons.eye, size: 16),
                                      ),
                                      MySpacing.width(20),
                                      /*MyContainer(
                                        onTap: () => controller.goEditScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        tooltip: MyContainer.shadow(
                                          borderRadius: BorderRadius.circular(5.0),
                                          color: Color.fromARGB(255, 245, 245, 245),
                                          paddingAll: 10,
                                          child: MyText.labelMedium("Editar",),
                                        ),
                                        child: Icon(LucideIcons.pencil, size: 16),
                                      ),
                                      MySpacing.width(20),*/
                                      MyContainer(
                                        onTap: () => controller.goPrescriptionScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        tooltip: MyContainer.shadow(
                                          borderRadius: BorderRadius.circular(5.0),
                                          color: Color.fromARGB(255, 245, 245, 245),
                                          paddingAll: 10,
                                          child: MyText.labelMedium("Recetas médicas",),
                                        ),
                                        child: Icon(LucideIcons.scroll, size: 16),
                                      ),
                                      MySpacing.width(20),
                                      MyContainer(
                                        onTap: () => controller.goStudiesScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        tooltip: MyContainer.shadow(
                                          borderRadius: BorderRadius.circular(5.0),
                                          color: Color.fromARGB(255, 245, 245, 245),
                                          paddingAll: 10,
                                          child: MyText.labelMedium("Estudios médicos",),
                                        ),
                                        child: Icon(LucideIcons.scroll_text, size: 16),
                                      ),
                                    ],
                                  ),
                                  ),
                                ],
                              ),).toList()),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MyText.bodyMedium("No tiene pacientes registrados", fontWeight: 800, muted: true),
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
}
