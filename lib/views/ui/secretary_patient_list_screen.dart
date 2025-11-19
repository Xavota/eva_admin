import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:medicare/controller/ui/secretary_patient_list_controller.dart';

import 'package:medicare/helpers/theme/app_themes.dart';
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

import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/db_manager.dart';
import 'package:blix_essentials/blix_essentials.dart';


class SecretaryPatientListScreen extends StatefulWidget {
  const SecretaryPatientListScreen({super.key});

  @override
  State<SecretaryPatientListScreen> createState() => _SecretaryPatientListScreenState();
}

class _SecretaryPatientListScreenState extends State<SecretaryPatientListScreen> with UIMixin {
  SecretaryPatientListController controller = Get.put(SecretaryPatientListController());

  @override
  void initState() {
    super.initState();
    controller.updatePatients();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tableFlexWidth = (1541 - 491 - (1920 - screenWidth));

    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'secretary_patient_list_controller',
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
                        MyBreadcrumbItem(name: 'Secretaria'),
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
                      MyText.bodyMedium("Listado de Pacientes", fontWeight: 600, muted: true),
                      MySpacing.height(15),
                      commonTextField(
                        title: "Nombre", hintText: "Nombre",
                        prefixIcon: Icon(Icons.search, size: 16),
                        onChange: controller.setNameFilter
                      ),
                      MySpacing.height(15),
                      MyText.labelMedium("Estatus", fontWeight: 600, muted: true),
                      MySpacing.height(8),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => controller.setStatusFilter(null),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<bool?>(
                                  value: null,
                                  activeColor: theme.colorScheme.primary,
                                  groupValue: controller.getStatusFilter(),
                                  onChanged: (value) => controller.setStatusFilter(value),
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
                                  groupValue: controller.getStatusFilter(),
                                  onChanged: (value) => controller.setStatusFilter(value),
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
                                  groupValue: controller.getStatusFilter(),
                                  onChanged: (value) => controller.setStatusFilter(value),
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
                      MySpacing.height(15),
                      MyText.labelMedium("Suscripción", fontWeight: 600, muted: true),
                      MySpacing.height(8),
                      Row(
                        children: [
                          InkWell(
                              onTap: () => controller.setSubscriptionFilter(null),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<SubscriptionStatus?>(
                                  value: null,
                                  activeColor: theme.colorScheme.primary,
                                  groupValue: controller.getSubscriptionFilter(),
                                  onChanged: (value) => controller.setSubscriptionFilter(value),
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
                            onTap: () => controller.setSubscriptionFilter(SubscriptionStatus.kActive),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<SubscriptionStatus?>(
                                  value: SubscriptionStatus.kActive,
                                  activeColor: theme.colorScheme.primary,
                                  groupValue: controller.getSubscriptionFilter(),
                                  onChanged: (value) => controller.setSubscriptionFilter(value),
                                  visualDensity: getCompactDensity,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                MySpacing.width(8),
                                MyText.labelMedium(
                                  "Activa",
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          InkWell(
                            onTap: () => controller.setSubscriptionFilter(SubscriptionStatus.kNotActive),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<SubscriptionStatus?>(
                                  value: SubscriptionStatus.kNotActive,
                                  activeColor: theme.colorScheme.primary,
                                  groupValue: controller.getSubscriptionFilter(),
                                  onChanged: (value) => controller.setSubscriptionFilter(value),
                                  visualDensity: getCompactDensity,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                MySpacing.width(8),
                                MyText.labelMedium(
                                  "No Activa",
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          InkWell(
                            onTap: () => controller.setSubscriptionFilter(SubscriptionStatus.kPending),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<SubscriptionStatus?>(
                                  value: SubscriptionStatus.kPending,
                                  activeColor: theme.colorScheme.primary,
                                  groupValue: controller.getSubscriptionFilter(),
                                  onChanged: (value) => controller.setSubscriptionFilter(value),
                                  visualDensity: getCompactDensity,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                MySpacing.width(8),
                                MyText.labelMedium(
                                  "Pendiente",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      MySpacing.height(15),
                      MyText.labelMedium("Motivo de Consulta", fontWeight: 600, muted: true),
                      MySpacing.height(8),
                      consultationReasonsFilter(),
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
                              dataRowMaxHeight: 80,
                              showBottomBorder: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              border: TableBorder.all(
                                  borderRadius: BorderRadius.circular(12), style: BorderStyle.solid, width: .4, color: contentTheme.secondary),
                              columns: [
                                DataColumn(label: MyText.labelMedium('Usuario', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Nombre', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Edad', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Motivos', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Estatus', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Suscripción', color: contentTheme.primary)),
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
                                  DataCell(SizedBox(width: 48, child: MyText.bodySmall(data.userNumber))),
                                  DataCell(SizedBox(width: math.max(tableFlexWidth * 0.6, 360), child: MyText.bodySmall(data.fullName))),
                                  DataCell(SizedBox(width: 35, child: MyText.bodySmall(data.age.toString()))),
                                  DataCell(SizedBox(width: math.max(tableFlexWidth * 0.4, 240), child: MyText.bodySmall(data.consultationReasons.map<String>((e) => e.name).join(", ")))),
                                  DataCell(SizedBox(width: 65, child: MyText.bodySmall(data.status ? "Activo" : "Archivado"))),
                                  DataCell(SizedBox(width: 75, child: MyText.bodySmall(switch (controller.patientSubStates[data.userNumber]) {
                                    SubscriptionStatus.kNotActive => "No Activa",
                                    SubscriptionStatus.kActive => "Activa",
                                    SubscriptionStatus.kPending => "Pendiente",
                                    null => "-"
                                  }))),
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
                                      /*MySpacing.width(20),
                                      MyContainer(
                                        onTap: () => controller.goEditScreen(index),
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(32),
                                        child: Icon(LucideIcons.pencil, size: 16),
                                      ),*/
                                    ],
                                  ),
                                  ),
                                ],
                              ),).toList()),
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

  Widget consultationReasonsFilter() {
    final reasons = (controller.getConsultReasonsFilter()?? []);
    return Container(
      key: ValueKey("secretary_patient_list_${reasons.join("_")}"),
      child: Column(
        children: [
          InputDecorator(
            isEmpty: reasons.isEmpty,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: "A qué viene a consulta",
              counterText: "",
              hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
              isCollapsed: true,
              isDense: true,
              prefixIcon: Icon(LucideIcons.heart_pulse, size: 16),
              contentPadding: MySpacing.all(2),
            ),
            child: MultiSelectDialogField<ConsultationReason>(
              initialValue: reasons,
              items: ConsultationReason.values
                  .map((category) => MultiSelectItem<ConsultationReason>(
                category,
                category.name.capitalize!,
              ))
                  .toList(),
              title: Text("Motivos de consulta"),
              confirmText: Text("Confirmar", style: TextStyle(color: contentTheme.primary),),
              cancelText: Text("Cancelar", style: TextStyle(color: contentTheme.danger),),
              searchable: true,
              checkColor: Colors.white,

              selectedColor: contentTheme.primary,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              buttonIcon: Icon(LucideIcons.chevron_down, size: 20),
              buttonText: Text(
                reasons.isEmpty ? "" : "Motivos de consutla",
                style: MyTextStyle.bodySmall(xMuted: true),
              ),
              chipDisplay: MultiSelectChipDisplay.none(),
              onConfirm: (values) {
                controller.setConsultReasonsFilter(values);
              },
            ),
          ),
          MySpacing.height(5),
          Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: reasons.map<Widget>((item) {
              return InkWell(
                onTap: () {
                  Debug.log("Removing: ${item.name}", overrideColor: Colors.red);
                  controller.removeConsultReasonsFilter(item);
                },
                child: Container(
                  width: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: contentTheme.primary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        item.name,
                        style: MyTextStyle.bodySmall(color: contentTheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
