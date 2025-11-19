import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:medicare/controller/ui/admin_doctor_subs_list_controller.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
//import 'package:medicare/helpers/utils/utils.dart';
//import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
//import 'package:medicare/images.dart';
import 'package:medicare/views/layout/layout.dart';
import 'package:medicare/helpers/theme/app_themes.dart';

//import 'package:blix_essentials/blix_essentials.dart';

class AdminDoctorSubsListScreen extends StatefulWidget {
  const AdminDoctorSubsListScreen({super.key});

  @override
  State<AdminDoctorSubsListScreen> createState() => _AdminDoctorSubsListScreenState();
}

class _AdminDoctorSubsListScreenState extends State<AdminDoctorSubsListScreen> with UIMixin {
  late AdminDoctorSubsListController controller;

  @override
  void initState() {
    super.initState();
    controller = AdminDoctorSubsListController();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_doctor_subs_list_controller',
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
                      MySpacing.height(15),
                      commonTextField(
                          title: "Nombre", hintText: "Nombre",
                          prefixIcon: Icon(Icons.search, size: 16),
                          onChange: controller.setNameFilter
                      ),
                      MySpacing.height(15),
                      MyText.labelMedium("Estatus", fontWeight: 600, muted: true),
                      MySpacing.height(8),
                      RadioGroup<bool?>(
                        groupValue: controller.getStatusFilter(),
                        onChanged: (value) => controller.setStatusFilter(value),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => controller.setStatusFilter(null),
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
                              onTap: () => controller.setStatusFilter(true),
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
                              onTap: () => controller.setStatusFilter(false),
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
                              DataColumn(label: MyText.labelMedium('Pacientes', color: contentTheme.primary)),
                              DataColumn(label: MyText.labelMedium('Suscripciones', color: contentTheme.primary)),
                              DataColumn(label: MyText.labelMedium('Porcentaje', color: contentTheme.primary)),
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
                                DataCell(SizedBox(width: 120, child: MyText.bodySmall(data.activePatients == 0 ? "No tiene" : data.activePatients.toString()))),
                                DataCell(SizedBox(width: 150, child: MyText.bodySmall(data.activePatientsWithSub == 0 ? "No tiene" : data.activePatientsWithSub.toString()))),
                                DataCell(SizedBox(width: 150, child: MyText.bodySmall(data.activePatients == 0 ? "0%" : "${((data.activePatientsWithSub / data.activePatients) * 100.0).round()}%"))),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyContainer(
                                        onTap: () => controller.goDetailDoctorScreen(index),
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
                                      MyContainer(
                                        onTap: () => controller.goEditDoctorScreen(index),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),).toList(),
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MyText.bodyMedium("No hay médicos activos", fontWeight: 800, muted: true),
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



  Widget commonTextField({
    String? title, String? hintText, bool readOnly = false,
    String? Function(String?)? validator, Widget? prefixIcon,
    void Function()? onTap, TextEditingController? teController,
    bool integer = false, bool floatingPoint = false, int? length,
    void Function(String)? onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(title ?? "", fontWeight: 600, muted: true),
        MySpacing.height(8),
        TextFormField(
          validator: validator,
          readOnly: readOnly,
          onTap: onTap ?? () {},
          controller: teController,
          keyboardType: integer ? TextInputType.phone : null,
          maxLength: length != null ? (length + (!integer && floatingPoint ? 3 : 0)) : null,
          inputFormatters: integer ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
              : (floatingPoint ? <TextInputFormatter>[FloatingPointTextInputFormatter(maxDigitsBeforeDecimal: length, maxDigitsAfterDecimal: 2)] : null),
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
          onChanged: onChange,
        ),
      ],
    );
  }
}
