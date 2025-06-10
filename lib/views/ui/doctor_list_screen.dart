import 'dart:math' as math;

import 'package:medicare/controller/ui/doctor_list_controller.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/images.dart';
import 'package:medicare/views/layout/layout.dart';
import 'package:medicare/helpers/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:blix_essentials/blix_essentials.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> with UIMixin {
  late DoctorListController controller;

  @override
  void initState() {
    super.initState();
    controller = DoctorListController();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_doctor_list_controller',
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
                      "Listado de Médicos",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Admin'),
                        MyBreadcrumbItem(name: 'Lista Médicos', active: true),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium("Listado de Médicos", fontWeight: 600, muted: true),
                          MyContainer(
                            onTap: controller.addDoctor,
                            padding: MySpacing.xy(12, 8),
                            borderRadiusAll: 8,
                            color: contentTheme.primary,
                            child: MyText.labelSmall("Registrar Médico",fontWeight: 600,color: contentTheme.onPrimary),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => controller.setActiveFilter(null),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<bool?>(
                                  value: null,
                                  activeColor: theme.colorScheme.primary,
                                  groupValue: controller.activeFilter,
                                  onChanged: (value) => controller.setActiveFilter(value),
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
                                  groupValue: controller.activeFilter,
                                  onChanged: (value) => controller.setActiveFilter(value),
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
                                  groupValue: controller.activeFilter,
                                  onChanged: (value) => controller.setActiveFilter(value),
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
                      /*Wrap(
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
                      ),*/
                      MySpacing.height(20),
                      if (controller.doctors.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortAscending: true,
                            sortColumnIndex: 0,
                            columnSpacing: 60,
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
                              DataColumn(label: MyText.labelMedium('Cédula Profesional', color: contentTheme.primary)),
                              DataColumn(label: MyText.labelMedium('Especialidad', color: contentTheme.primary)),
                              DataColumn(label: MyText.labelMedium('Estatus', color: contentTheme.primary)),
                              DataColumn(label: MyText.labelMedium('Acciones', color: contentTheme.primary)),
                            ],
                            rows: controller.doctors
                                .mapIndexed((index, data) => DataRow(
                              cells: [
                                /*DataCell(SizedBox(
                                  width: 150,
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
                                      MyText.bodySmall(data.doctorName),
                                    ],
                                  ),
                                )),*/
                                DataCell(SizedBox(width: 50, child: MyText.bodySmall(data.userNumber))),
                                DataCell(SizedBox(width: math.max(1605 - 1017 - (1920 - screenWidth), 200), child: MyText.bodySmall(data.fullName))),
                                DataCell(SizedBox(width: 120, child: MyText.bodySmall(data.professionalNumber))),
                                DataCell(SizedBox(width: 150, child: MyText.bodySmall(data.speciality))),
                                /// TODO: Poner un botón para cambiar este estado y lo demás de la tarea.
                                DataCell(SizedBox(width: 150, child: MyText.bodySmall(data.status ? "Activo" : "Archivado"))),
                                DataCell(
                                  Row(
                                    children: [
                                      MyContainer(
                                        onTap: () => controller.changeDoctorStatus(index, !data.status).then((response) {
                                          if (context.mounted) {
                                            if (response) {
                                              simpleSnackBar(context, "Médico ${(data.status ? "" : "des")}archivado con éxito", contentTheme.success);// Color(0XFFAA236E));
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
                                        child: Icon(data.status ? LucideIcons.archive : LucideIcons.archive_restore, size: 16),
                                      ),
                                      MySpacing.width(20),
                                      MyContainer(
                                        onTap: () => controller.goDetailDoctorScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        child: Icon(LucideIcons.eye, size: 16),
                                      ),
                                      MySpacing.width(20),
                                      MyContainer(
                                        onTap: () => controller.goEditDoctorScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        child: Icon(LucideIcons.pencil, size: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
