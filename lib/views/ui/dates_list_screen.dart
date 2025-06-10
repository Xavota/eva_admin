import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:medicare/controller/ui/dates_list_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:medicare/app_constant.dart';


class DatesListScreen extends StatefulWidget {
  const DatesListScreen({super.key});

  @override
  State<DatesListScreen> createState() => _DatesListScreenState();
}

class _DatesListScreenState extends State<DatesListScreen> with UIMixin {
  DatesListController controller = Get.put(DatesListController());

  @override
  void initState() {
    super.initState();
    controller.updateDates();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tableFlexWidth = (1541 - 319 - (1920 - screenWidth));

    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_patient_list_controller',
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
                      "Listado de Citas",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Lista Citas', active: true),
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
                      MyText.bodyMedium("Listado de Citas", fontWeight: 600, muted: true),
                      MySpacing.height(15),
                      commonTextField(
                        title: "Nombre", hintText: "Nombre",
                        prefixIcon: Icon(Icons.search, size: 16),
                        onChange: controller.setNameFilter
                      ),
                      MySpacing.height(15),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: commonTextField(
                              title: "Día",
                              hintText: "Selecciona una fecha",
                              validator: controller.basicValidator.getValidation("dateFilter"),
                              teController: controller.basicValidator.getController("dateFilter"),
                              prefixIcon: Icon(LucideIcons.calendar, size: 16),
                              onTap: controller.pickDateFilter,
                              readOnly: true,
                            ),
                          ),
                          MySpacing.width(10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: MyContainer(
                              onTap: controller.removeDayFilter,
                              paddingAll: 8,
                              color: contentTheme.secondary.withAlpha(32),
                              child: Icon(Icons.close, size: 16),
                            ),
                          ),
                        ],
                      ),
                      MySpacing.height(20),
                      if (controller.dates.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              sortAscending: true,
                              columnSpacing: 30,
                              horizontalMargin: 15.0,
                              onSelectAll: (_) => {},
                              headingRowColor: WidgetStatePropertyAll(contentTheme.primary.withAlpha(40)),
                              dataRowMaxHeight: 80,
                              showBottomBorder: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              border: TableBorder.all(
                                  borderRadius: BorderRadius.circular(12), style: BorderStyle.solid, width: .4, color: contentTheme.secondary),
                              columns: [
                                DataColumn(label: MyText.labelMedium('Nombre', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Teléfono', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Fecha', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Motivos', color: contentTheme.primary)),
                                //DataColumn(label: MyText.labelMedium('Acciones', color: contentTheme.primary)),
                              ],
                              rows: controller.dates
                                  .mapIndexed((index, data) => DataRow(
                                cells: [
                                  DataCell(SizedBox(width: math.max(tableFlexWidth * 0.6, 360), child: MyText.bodySmall(controller.getFullName(data)))),
                                  DataCell(SizedBox(width: 80, child: MyText.bodySmall(data.phoneNumber))),
                                  DataCell(SizedBox(width: 120, child: MyText.bodySmall(controller.getDateFormatted(data.date)))),
                                  DataCell(SizedBox(width: math.max(tableFlexWidth * 0.4, 240), child: MyText.bodySmall(controller.getConsulReasons(data)))),
                                  /*DataCell(Row(
                                    children: [
                                      /*MyContainer(
                                        onTap: () => controller.changePatientStatus(index, !data.status).then((response) {
                                          if (context.mounted) {
                                            if (response) {
                                              simpleSnackBar(context, "Tratante ${(data.status ? "" : "des")}archivado con éxito", contentTheme.success);// Color(0XFFAA236E));
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
                                      MySpacing.width(20),*/
                                      MyContainer(
                                        onTap: () => controller.goDetailScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        child: Icon(LucideIcons.eye, size: 16),
                                      ),
                                      /*MySpacing.width(20),
                                      MyContainer(
                                        onTap: () => controller.goEditScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        child: Icon(LucideIcons.pencil, size: 16),
                                      ),*/
                                    ],
                                  ),
                                  ),*/
                                ],
                              ),).toList()),
                        ),
                      if (controller.dates.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MyText.bodyMedium("No hay Citas Registradas", fontWeight: 800, muted: true),
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
