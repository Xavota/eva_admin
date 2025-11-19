import 'dart:math' as math;

import 'package:blix_essentials/blix_essentials.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:medicare/controller/ui/admin_doctor_earnings_list_controller.dart';
import 'package:medicare/helpers/theme/admin_theme.dart';

import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';


class AdminDoctorEarningsListScreen extends StatefulWidget {
  const AdminDoctorEarningsListScreen({super.key});

  @override
  State<AdminDoctorEarningsListScreen> createState() => _AdminDoctorEarningsListScreenState();
}

class _AdminDoctorEarningsListScreenState extends State<AdminDoctorEarningsListScreen> with SingleTickerProviderStateMixin, UIMixin {
  AdminDoctorEarningsListController controller = Get.put(AdminDoctorEarningsListController());

  int instanceIndex = -1;
  bool firstFrame = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.contextInstance.addInstance();

    controller.updateInfo(instanceIndex).then((_) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    Debug.log(MyScreenMedia.getTypeFromWidth(screenWidth).name, overrideColor: Colors.purpleAccent);

    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_doctor_earnings_list_controller',
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

          double? titlesSize(double? width, double extraPadding) {
            return width == null ? null : width + extraPadding;
          }

          return Stack(
            key: controller.contextInstance.getContentKey(instanceIndex, "global"),
            children: [
              Column(
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
                            "Ganancias Mensuales",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Admin'),
                              MyBreadcrumbItem(name: 'Contenido Premium', active: true),
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
                      child: Column(
                        key: controller.contextInstance.getContentKey(instanceIndex, "content"),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.labelMedium("Mes", fontWeight: 600, muted: true),
                                    MySpacing.height(8),
                                    DropdownButtonFormField<Months>(
                                      dropdownColor: contentTheme.background,
                                      isDense: true,
                                      style: MyTextStyle.bodySmall(),
                                      items: Months.values
                                          .map((category) => DropdownMenuItem<Months>(
                                        value: category,
                                        child: MyText.bodySmall(category.name.capitalize!),
                                      ),).toList(),
                                      initialValue: Months.values[controller.data[instanceIndex]!.currentTime.month - 1],
                                      icon: Icon(LucideIcons.chevron_down, size: 20),
                                      decoration: InputDecoration(
                                        hintText: "Elige Mes",
                                        hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        contentPadding: MySpacing.all(12),
                                        isCollapsed: true,
                                        isDense: true,
                                        prefixIcon: Icon(LucideIcons.calendar, size: 16),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                      ),
                                      onChanged: (month) => controller.onMonthChanged(instanceIndex, (month?.index?? 0) + 1),
                                    ),
                                  ],
                                ),
                              ),
                              MySpacing.width(20.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.labelMedium("Año", fontWeight: 600, muted: true),
                                    MySpacing.height(8),
                                    DropdownButtonFormField<int>(
                                      dropdownColor: contentTheme.background,
                                      isDense: true,
                                      style: MyTextStyle.bodySmall(),
                                      items: List.generate(100, (i) => 2025 + i)
                                          .map((year) => DropdownMenuItem<int>(
                                        value: year,
                                        child: MyText.bodySmall(year.toString()),
                                      ),).toList(),
                                      initialValue: controller.data[instanceIndex]!.currentTime.year,
                                      icon: Icon(LucideIcons.chevron_down, size: 20),
                                      decoration: InputDecoration(
                                        hintText: "Elige Año",
                                        hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        contentPadding: MySpacing.all(12),
                                        isCollapsed: true,
                                        isDense: true,
                                        prefixIcon: Icon(LucideIcons.calendar_1, size: 16),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                      ),
                                      onChanged: (year) => controller.onYearChanged(instanceIndex, year?? 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          MySpacing.height(20.0),
                          commonTextField(
                            title: "Precio Mensual", hintText: "0.00",
                            prefixIcon: Icon(Icons.attach_money, size: 16),
                            onChange: (text) => controller.onPriceChanged(instanceIndex, text),
                            floatingPoint: true,
                          ),
                          MySpacing.height(20.0),
                          if (controller.data[instanceIndex]!.tableData.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                sortAscending: true,
                                sortColumnIndex: 0,
                                columnSpacing: 30,
                                onSelectAll: (_) => {},
                                headingRowColor: WidgetStatePropertyAll(contentTheme.primary.withAlpha(40)),
                                dataRowMaxHeight: 60,
                                showBottomBorder: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                border: TableBorder.all(
                                    borderRadius: BorderRadius.circular(12), style: BorderStyle.solid, width: .4, color: contentTheme.secondary),
                                columns: [
                                  DataColumn(label: MyText.labelMedium('Médico', color: contentTheme.primary)),
                                  DataColumn(label: MyText.labelMedium('Nuevos\nSuscriptores', color: contentTheme.primary)),
                                  DataColumn(label: MyText.labelMedium('Meses\nactivados', color: contentTheme.primary)),
                                  DataColumn(label: MyText.labelMedium('Ingresos', color: contentTheme.primary)),
                                  DataColumn(label: MyText.labelMedium('Estatus', color: contentTheme.primary)),
                                  DataColumn(label: MyText.labelMedium('Acciones', color: contentTheme.primary)),
                                ],
                                rows: controller.tableData(instanceIndex)
                                    .mapIndexed((index, data) => DataRow(
                                  cells: [
                                    DataCell(SizedBox(width: math.max(screenWidth - contentPadding * 2 - 858, 150), child: MyText.bodySmall(data.doctorName))),
                                    DataCell(SizedBox(width: 80, child: MyText.bodySmall(data.subsCount.toString()))),
                                    DataCell(SizedBox(width: 62, child: MyText.bodySmall(data.monthsCount.toString()))),
                                    DataCell(SizedBox(width: 70, child: MyText.bodySmall("\$ ${formatMoney(data.monthsCount * controller.data[instanceIndex]!.price)}"))),
                                    DataCell(SizedBox(width: 50, child: MyText.bodySmall(data.payed ? "Pagado" : "Sin Pagar"))),
                                    DataCell(
                                      SizedBox(
                                        width: 60,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            MyContainer(
                                              onTap: () => controller.changePayedStatus(instanceIndex, index, !data.payed).then((response) {
                                                if (context.mounted) {
                                                  if (response) {
                                                    simpleSnackBar(context, "Estatus cambiado correctamente", contentTheme.success);// Color(0XFFAA236E));
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
                                                child: MyText.labelMedium("Cambiar estatus",),
                                              ),
                                              child: Icon(data.payed ? LucideIcons.archive : LucideIcons.archive_restore, size: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),).toList(),
                              ),
                            )
                          else
                            MyText.bodySmall("No hay suscripciones activadas durante este mes."),
                        ],
                      ),
                    ),
                  )
                ],
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
