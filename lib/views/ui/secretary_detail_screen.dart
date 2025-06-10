import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:medicare/images.dart';
import 'package:medicare/app_constant.dart';

import 'package:medicare/controller/ui/secretary_detail_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/utils.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
//import 'package:medicare/helpers/widgets/my_flex.dart';
//import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/helpers/widgets/my_file_selector.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:medicare/model/secretary_model.dart';

import 'package:blix_essentials/blix_essentials.dart';


class SecretaryDetailScreen extends StatefulWidget {
  const SecretaryDetailScreen({super.key});

  @override
  State<SecretaryDetailScreen> createState() => _SecretaryDetailScreenState();
}

class _SecretaryDetailScreenState extends State<SecretaryDetailScreen> with UIMixin {
  SecretaryDetailController controller = Get.put(SecretaryDetailController());


  @override
  void initState() {
    super.initState();

    controller.updateSecretaryInfo().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_secretary_detail_controller',
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
                      "Detalles de Secretari@",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Detalles Secretari@', active: true),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: secretaryDetail(),
              ),
              /*Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: MyFlex(
                  children: [
                    MyFlexItem(sizes: 'lg-4 md-6', child: secretaryDetail()),
                    MyFlexItem(
                        sizes: 'lg-8 md-6',
                        child: Column(
                          children: [about(), MySpacing.height(20), generalReport()],
                        )),
                    MyFlexItem(sizes: 'lg-6 md-6', child: doctorVisit()),
                    MyFlexItem(sizes: 'lg-6 md-6', child: report()),
                  ],
                ),
              ),*/
            ],
          );
        },
      ),
    );
  }

  Widget secretaryDetail() {
    Widget details(String title, String detail) {
      return Row(
        children: [
          SizedBox(width: 200.0, child: MyText.bodySmall(title, fontWeight: 600, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Flexible(child: MyText.bodySmall(detail, muted: true, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      );
    }

    return MyContainer(
      paddingAll: 24,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium("Detalles", fontWeight: 600, muted: true),
              MyContainer(
                onTap: controller.goEditScreen,
                padding: MySpacing.xy(12, 8),
                borderRadiusAll: 8,
                color: contentTheme.primary,
                child: MyText.labelSmall("Editar Secretari@", fontWeight: 600, color: contentTheme.onPrimary),
              )
            ],
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium("Detalles", fontWeight: 600),
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(height: 32, child: MyText.labelSmall("CSV")),
                    PopupMenuItem(height: 32, child: MyText.labelSmall("Print")),
                    PopupMenuItem(height: 32, child: MyText.labelSmall("PDF")),
                    PopupMenuItem(height: 32, child: MyText.labelSmall("Excel")),
                  ];
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                offset: Offset(0, 26),
                child: Icon(LucideIcons.ellipsis_vertical, size: 16),
              )
            ],
          ),*/
          MySpacing.height(20),
          /*Center(
            child: MyContainer(
              paddingAll: 0,
              height: 200,
              width: 200,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadiusAll: 8,
              child: Image.asset(Images.avatars[2], fit: BoxFit.cover),
            ),
          ),
          MySpacing.height(20),*/
          details("Nombre", controller.selectedSecretary?.fullName?? "Nadie"),
        ],
      ),
    );
  }

  Widget about() {
    return MyContainer(
      paddingAll: 24,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("About", fontWeight: 600),
          MySpacing.height(20),
          MyText.bodySmall(controller.dummyTexts[0], muted: true),
          MySpacing.height(20),
          MyText.bodySmall(controller.dummyTexts[1], muted: true),
        ],
      ),
    );
  }

  Widget generalReport() {
    Widget generalReportWidget(String title, String progress, double value, Color color) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodySmall(title, fontWeight: 600),
              MyText.bodySmall(progress),
            ],
          ),
          MySpacing.height(12),
          LinearProgressIndicator(
            value: value,
            minHeight: 9,
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
        ],
      );
    }

    return MyContainer(
      paddingAll: 20,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("General Report", fontWeight: 600),
          MySpacing.height(20),
          generalReportWidget("Heart Beat", '34', .8, contentTheme.primary),
          MySpacing.height(20),
          generalReportWidget("Blood Pressure", '93', .93, contentTheme.danger),
          MySpacing.height(20),
          generalReportWidget("Sugar", '55', .55, contentTheme.info),
          MySpacing.height(20),
          generalReportWidget("Haemoglobin", '78', .78, contentTheme.warning),
        ],
      ),
    );
  }

  Widget doctorVisit() {
    return MyContainer(
      paddingAll: 20,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("Doctor Visit", fontWeight: 600),
          MySpacing.height(20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
                border: TableBorder.all(borderRadius: BorderRadius.circular(12), style: BorderStyle.solid, width: .4, color: contentTheme.secondary),
                columnSpacing: 100,
                dataRowMaxHeight: 75,
                dataRowMinHeight: 75,
                columns: [
                  DataColumn(label: MyText.bodyMedium("Doctor", fontWeight: 600)),
                  DataColumn(label: MyText.bodyMedium("Date", fontWeight: 600)),
                  DataColumn(label: MyText.bodyMedium("Department", fontWeight: 600)),
                  DataColumn(label: MyText.bodyMedium("Reports", fontWeight: 600)),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Row(
                      children: [
                        MyContainer(
                          paddingAll: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          height: 32,
                          width: 32,
                          child: Image.asset(Images.avatars[6], fit: BoxFit.cover),
                        ),
                        MySpacing.width(12),
                        MyText.bodySmall("Dr. Christian"),
                      ],
                    )),
                    DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2024-10-11T00:00:00Z')))),
                    DataCell(MyText.bodySmall("Dentist")),
                    DataCell(MyContainer(
                      onTap: () {},
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.primary,
                      child: MyText.bodySmall("View Report", fontWeight: 600, color: contentTheme.onPrimary),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Row(
                      children: [
                        MyContainer(
                          paddingAll: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          height: 32,
                          width: 32,
                          child: Image.asset(Images.avatars[7], fit: BoxFit.cover),
                        ),
                        MySpacing.width(12),
                        MyText.bodySmall("Dr. Leonard"),
                      ],
                    )),
                    DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2023-12-12T12:30:00Z')))),
                    DataCell(MyText.bodySmall("Urologist")),
                    DataCell(MyContainer(
                      onTap: () {},
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.primary,
                      child: MyText.bodySmall("View Report", fontWeight: 600, color: contentTheme.onPrimary),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Row(
                      children: [
                        MyContainer(
                          paddingAll: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          height: 32,
                          width: 32,
                          child: Image.asset(Images.avatars[8], fit: BoxFit.cover),
                        ),
                        MySpacing.width(12),
                        MyText.bodySmall("Dr. Sebastian"),
                      ],
                    )),
                    DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2023-09-13T18:45:00Z')))),
                    DataCell(MyText.bodySmall("Surgeon")),
                    DataCell(MyContainer(
                      onTap: () {},
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.primary,
                      child: MyText.bodySmall("View Report", fontWeight: 600, color: contentTheme.onPrimary),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Row(
                      children: [
                        MyContainer(
                          paddingAll: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          height: 32,
                          width: 32,
                          child: Image.asset(Images.avatars[9], fit: BoxFit.cover),
                        ),
                        MySpacing.width(12),
                        MyText.bodySmall("Dr. Thomas"),
                      ],
                    )),
                    DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2023-05-14T07:15:00Z')))),
                    DataCell(MyText.bodySmall("Dentist")),
                    DataCell(MyContainer(
                      onTap: () {},
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.primary,
                      child: MyText.bodySmall("View Report", fontWeight: 600, color: contentTheme.onPrimary),
                    )),
                  ]),
                ]),
          )
        ],
      ),
    );
  }

  Widget report() {
    return MyContainer(
      paddingAll: 20,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("Report", fontWeight: 600),
          MySpacing.height(20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
                border: TableBorder.all(borderRadius: BorderRadius.circular(12), style: BorderStyle.solid, width: .4, color: contentTheme.secondary),
                dataRowMaxHeight: 75,
                dataRowMinHeight: 75,
                columns: [
              DataColumn(label: MyText.bodyMedium("File", fontWeight: 600)),
              DataColumn(label: SizedBox(width: 300, child: MyText.bodyMedium("Report Link", fontWeight: 600))),
              DataColumn(label: SizedBox(width: 100, child: MyText.bodyMedium("Date", fontWeight: 600))),
              DataColumn(label: MyText.bodyMedium("Action", fontWeight: 600)),
            ], rows: [
              DataRow(cells: [
                DataCell(MyContainer(
                  onTap: () {},
                  paddingAll: 8,
                  color: contentTheme.primary,
                  child: Icon(LucideIcons.file_archive, size: 16, color: contentTheme.onPrimary),
                )),
                DataCell(InkWell(onTap: () {}, child: MyText.bodySmall("Reports 1 clinical documentation"))),
                DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2023-12-12T12:30:00Z'), showMonthShort: true))),
                DataCell(Row(
                  children: [
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.primary,
                      child: Icon(LucideIcons.file, size: 16, color: contentTheme.onPrimary),
                    ),
                    MySpacing.width(20),
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.danger,
                      child: Icon(LucideIcons.trash, size: 16, color: contentTheme.onDanger),
                    ),
                  ],
                )),
              ]),
              DataRow(cells: [
                DataCell(MyContainer(
                  onTap: () {},
                  paddingAll: 8,
                  color: contentTheme.primary,
                  child: Icon(LucideIcons.file_archive, size: 16, color: contentTheme.onPrimary),
                )),
                DataCell(InkWell(onTap: () {}, child: MyText.bodySmall("Reports 2 random files documentation"))),
                DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2023-09-13T18:45:00Z'), showMonthShort: true))),
                DataCell(Row(
                  children: [
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.primary,
                      child: Icon(LucideIcons.file, size: 16, color: contentTheme.onPrimary),
                    ),
                    MySpacing.width(20),
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.danger,
                      child: Icon(LucideIcons.trash, size: 16, color: contentTheme.onDanger),
                    ),
                  ],
                )),
              ]),
              DataRow(cells: [
                DataCell(MyContainer(
                  onTap: () {},
                  paddingAll: 8,
                  color: contentTheme.primary,
                  child: Icon(LucideIcons.file_archive, size: 16, color: contentTheme.onPrimary),
                )),
                DataCell(InkWell(onTap: () {}, child: MyText.bodySmall("Reports 3 glucose level complete report"))),
                DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2023-05-14T07:15:00Z'), showMonthShort: true))),
                DataCell(Row(
                  children: [
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.primary,
                      child: Icon(LucideIcons.file, size: 16, color: contentTheme.onPrimary),
                    ),
                    MySpacing.width(20),
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.danger,
                      child: Icon(LucideIcons.trash, size: 16, color: contentTheme.onDanger),
                    ),
                  ],
                )),
              ]),
              DataRow(cells: [
                DataCell(MyContainer(
                  onTap: () {},
                  paddingAll: 8,
                  color: contentTheme.primary,
                  child: Icon(LucideIcons.file_archive, size: 16, color: contentTheme.onPrimary),
                )),
                DataCell(InkWell(onTap: () {}, child: MyText.bodySmall("Reports 4 clinical documentation"))),
                DataCell(MyText.bodySmall(Utils.getDateStringFromDateTime(DateTime.parse('2024-10-11T00:00:00Z'), showMonthShort: true))),
                DataCell(Row(
                  children: [
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.primary,
                      child: Icon(LucideIcons.file, size: 16, color: contentTheme.onPrimary),
                    ),
                    MySpacing.width(20),
                    MyContainer(
                      onTap: () {},
                      paddingAll: 8,
                      color: contentTheme.danger,
                      child: Icon(LucideIcons.trash, size: 16, color: contentTheme.onDanger),
                    ),
                  ],
                )),
              ]),
            ]),
          )
        ],
      ),
    );
  }
}
