import 'package:medicare/controller/ui/doctor_list_controller.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/images.dart';
import 'package:medicare/views/layout/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> with UIMixin {
  late DoctorListController controller;

  @override
  void initState() {
    controller = DoctorListController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      "Doctor List",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Admin'),
                        MyBreadcrumbItem(name: 'Doctor List', active: true),
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
                          MyText.bodyMedium("Doctor List", fontWeight: 600, muted: true),
                          MyContainer(
                            onTap: controller.addDoctor,
                            padding: MySpacing.xy(12, 8),
                            borderRadiusAll: 8,
                            color: contentTheme.primary,
                            child: MyText.labelSmall("Add Doctor",fontWeight: 600,color: contentTheme.onPrimary),
                          )
                        ],
                      ),
                      MySpacing.height(20),
                      if (controller.doctors.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              sortAscending: true,
                              columnSpacing: 60,
                              onSelectAll: (_) => {},
                              headingRowColor: WidgetStatePropertyAll(contentTheme.primary.withAlpha(40)),
                              dataRowMaxHeight: 60,
                              showBottomBorder: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              border: TableBorder.all(
                                  borderRadius: BorderRadius.circular(12), style: BorderStyle.solid, width: .4, color: contentTheme.secondary),
                              columns: [
                                DataColumn(label: MyText.labelMedium('Name', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Designation', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Email', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Degree', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Mobile Number', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Joining Date', color: contentTheme.primary)),
                                DataColumn(label: MyText.labelMedium('Action', color: contentTheme.primary)),
                              ],
                              rows: controller.doctors
                                  .mapIndexed((index, data) => DataRow(cells: [
                                        DataCell(SizedBox(
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
                                        )),
                                        DataCell(SizedBox(width: 150, child: MyText.bodySmall(data.designation))),
                                        DataCell(SizedBox(width: 250, child: MyText.bodySmall(data.email))),
                                        DataCell(SizedBox(width: 100, child: MyText.bodySmall(data.degree))),
                                        DataCell(SizedBox(width: 150, child: MyText.bodySmall(data.mobileNumber))),
                                        DataCell(SizedBox(width: 150, child: MyText.bodySmall(Utils.getDateStringFromDateTime(data.joiningDate)))),
                                        DataCell(Row(
                                          children: [
                                            MyContainer(
                                              onTap: controller.goDetailDoctorScreen,
                                              paddingAll: 8,
                                              color: contentTheme.secondary.withAlpha(32),
                                              child: Icon(LucideIcons.eye, size: 16),
                                            ),
                                            MySpacing.width(20),
                                            MyContainer(
                                              onTap: controller.goEditDoctorScreen,
                                              paddingAll: 8,
                                              color: contentTheme.secondary.withAlpha(32),
                                              child: Icon(LucideIcons.pencil, size: 16),
                                            ),
                                          ],
                                        )),
                                      ]))
                                  .toList()),
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
