import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:medicare/helpers/theme/app_themes.dart';

import 'package:medicare/images.dart';
import 'package:medicare/app_constant.dart';

import 'package:medicare/controller/ui/doctor_patient_detail_controller.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
//import 'package:medicare/helpers/widgets/my_flex.dart';
//import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/my_flex.dart';
import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/helpers/widgets/my_file_selector.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_form.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/daily_record_model.dart';

import 'package:medicare/db_manager.dart';
import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientDetailScreen extends StatefulWidget {
  const DoctorPatientDetailScreen({super.key});

  @override
  State<DoctorPatientDetailScreen> createState() => _DoctorPatientDetailScreenState();
}

class _DoctorPatientDetailScreenState extends State<DoctorPatientDetailScreen> with UIMixin {
  DoctorPatientDetailController controller = Get.put(DoctorPatientDetailController());


  @override
  void initState() {
    super.initState();

    controller.calendarCurrentMonth = DateTime.now().month;
    controller.calendarCurrentYear = DateTime.now().year;

    final String param = Get.parameters['index']!;
    final int index = int.parse(param);
    controller.updatePatientInfo(index).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'admin_patient_detail_controller',
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
                      "Detalles del Tratante",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Médico'),
                        MyBreadcrumbItem(name: 'Detalles Tratante', active: true),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: patientDetail(),
              ),
              MySpacing.height(10),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: pdfViewer(),
              ),
              MySpacing.height(10),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: patientGraphs(),
              ),
              /*Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: MyFlex(
                  children: [
                    MyFlexItem(sizes: 'lg-4 md-6', child: patientDetail()),
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

  Widget patientDetail() {
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
                child: MyText.labelSmall("Editar Tratante", fontWeight: 600, color: contentTheme.onPrimary),
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
          details("Nombre", controller.selectedPatient?.fullName?? "Nadie"),
          MySpacing.height(20),
          details("Edad", "${controller.selectedPatient?.age.toString()?? "0"} años"),
          MySpacing.height(20),
          details("Sexo", controller.selectedPatient?.sex.name?? "N/A"),
          MySpacing.height(20),
          details("Peso", "${controller.selectedPatient?.weight.toString()?? "0.0"} Kg"),
          MySpacing.height(20),
          details("Altura", "${controller.selectedPatient?.height.toString()} m"),
          MySpacing.height(20),
          details("Cintura", "${controller.selectedPatient?.waist.toString()} cm"),
          MySpacing.height(20),
          details("Ocupación", controller.selectedPatient?.job?? "Ninguna"),
          MySpacing.height(20),
          details("Fecha de Nacimiento", dateFormatter.format(controller.selectedPatient?.birthDate?? DateTime.now())),
          MySpacing.height(20),
          details("Número de Teléfono", controller.selectedPatient?.phoneNumber?? "0000000000"),
          MySpacing.height(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 200, child: MyText.bodySmall("Motivos de Consulta", fontWeight: 600, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controller.selectedPatient?.consultationReasons.map<Widget>(
                          (e) => MyText.bodySmall(
                            e.name, muted: true, maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                  ).toList()?? [],
                ),
              ),
            ],
          ),
          MySpacing.height(40),
          details("Suscripción", switch (controller.subscriptionStatus) {
            SubscriptionStatus.kNotActive => "No Activa",
            SubscriptionStatus.kActive => "Activa",
            SubscriptionStatus.kPending => "Pendiente",
            null => "-"
          }),
        ],
      ),
    );
  }

  Widget pdfViewer() {
    final pdfName = controller.selectedPatient?.pdfName?? "";
    final pdfURL = BlixDBManager.getUrl("uploads/pdf/$pdfName");
    Debug.log("pdfURL: $pdfURL");
    return MyContainer(
      paddingAll: 24,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("PDF", fontWeight: 600),
          MySpacing.height(20),
          MyText.bodyMedium(pdfName.isEmpty ? "No hay expediente cargado" : "Expediente cargado", fontWeight: 600),
          if (pdfName.isNotEmpty)
            MySpacing.height(10),
          if (pdfName.isNotEmpty)
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                //if (pdfName.isNotEmpty/* && controller.pdfBytes != null*/)
                MyContainer(
                  onTap: () {
                    controller.showPDFPreview(context);
                  },
                  padding: MySpacing.xy(12, 8),
                  color: contentTheme.primary,
                  borderRadiusAll: 8,
                  child: MyText.labelMedium("Ver expediente", color: contentTheme.onPrimary, fontWeight: 600),
                ),
                //if (pdfName.isNotEmpty)
                MyContainer(
                  onTap: () {
                    controller.deletePDFFile().then((error) {
                      if (!mounted) return;

                      if (error == null) {
                        simpleSnackBar(context, "El archivo se eliminó correctamente", contentTheme.success);
                      }
                      else if (error == "no user") {
                        simpleSnackBar(context, "No hay un usuario seleccionado", contentTheme.danger);
                      }
                      else if (error == "no such file") {
                        simpleSnackBar(context, "El archivo no existe", contentTheme.danger);
                      }
                    });
                  },
                  padding: MySpacing.xy(12, 8),
                  color: contentTheme.danger,
                  borderRadiusAll: 8,
                  child: MyText.labelMedium("Eliminar expediente", color: contentTheme.onPrimary, fontWeight: 600),
                ),
              ],
            ),
          MySpacing.height(20),
          FileUploadWidget(
            hintText: "Arrastra aquí el archivo o",
            uploadButtonText: "busca en tus archivos",
            icon: Icons.picture_as_pdf,
            allowedFormats: [MyFormats.pdf],
            onFileSelected: controller.loadPDFFile,
            onError: (error) {
              if (error == "type" || error == "unsupported") {
                simpleSnackBar(context, "El archivo no es un PDF", contentTheme.danger);
              }
              else if (error == "size") {
                simpleSnackBar(context, "El archivo pesa más de 10MB", contentTheme.danger);
              }
              else if (error == "read") {
                simpleSnackBar(context, "El archivo no pudo leerse correctamente", contentTheme.danger);
              }
            },
          ),
          MySpacing.height(10),
          MyContainer(
            onTap: () {
              controller.uploadPDFFile().then((error) {
                if (!mounted) return;

                if (error == null) {
                  simpleSnackBar(context, "El archivo se subió correctamente", contentTheme.success);
                }
                else if (error == "missing info") {
                  simpleSnackBar(context, "No hay un archivo seleccionado", contentTheme.danger);
                }
                else if (error == "type") {
                  simpleSnackBar(context, "El archivo no es un PDF", contentTheme.danger);
                }
                else if (error == "size") {
                  simpleSnackBar(context, "El archivo pesa más de 10MB", contentTheme.danger);
                }
                else if (error == "file error") {
                  simpleSnackBar(context, "Hubo un error con el archivo o con el servidor", contentTheme.danger);
                }
                else if (error == "failed") {
                  simpleSnackBar(context, "Hubo un fallo subiendo el archivo al servidor", contentTheme.danger);
                }
                else if (error == "no user") {
                  simpleSnackBar(context, "No hay un usuario seleccionado", contentTheme.danger);
                }
              });
            },
            padding: MySpacing.xy(12, 8),
            color: contentTheme.primary,
            borderRadiusAll: 8,
            child: MyText.labelMedium("Subir", color: contentTheme.onPrimary, fontWeight: 600),
          ),
        ],
      ),
    );
  }

  Widget patientGraphs() {
    return MyContainer(
      paddingAll: 24,
      borderRadiusAll: 12,
      child: Column(
        children: [
          MyForm(
            //key: controller.basicValidator.formKey,
            addNewFormKey: controller.addNewFormKey,
            disposeFormKey: controller.disposeFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium("Metas del Tratante", fontWeight: 600),
                MySpacing.height(20),
                MyFlex(
                  contentPadding: false,
                  children: [
                    MyFlexItem(
                      sizes: 'lg-6 md-6',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          commonTextField(
                            title: "Meta de Peso", hintText: "Ninguna",
                            validator: controller.basicValidator.getValidation("weightGoal"),
                            teController: controller.basicValidator.getController("weightGoal"),
                            prefixIcon: Icon(Icons.scale, size: 16),
                            floatingPoint: true, length: 3,
                          ),
                        ],
                      ),
                    ),
                    MyFlexItem(
                      sizes: 'lg-6 md-6',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          commonTextField(
                            title: "Meta de Cintura", hintText: "Ninguna",
                            validator: controller.basicValidator.getValidation("waistGoal"),
                            teController: controller.basicValidator.getController("waistGoal"),
                            prefixIcon: Icon(LucideIcons.ruler, size: 16),
                            floatingPoint: true, length: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                MySpacing.height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyContainer(
                      onTap: () {
                        controller.onUpdate().then((validationError) {
                          DBManager.instance!.getPatients(doctorOwnerID: AuthService.loggedUserNumber).then((_) {
                            controller.updatePatientInfo();//.then((_) => setState(() {}));
                          });
                          if (!mounted) return;
                          if (validationError != null) {
                            simpleSnackBar(context, validationError, contentTheme.danger);// Color(0XFFAA236E));
                          }
                          else {
                            simpleSnackBar(context, "Tratante editado con éxito", contentTheme.success);// Color(0xFF35639D));
                          }
                        });
                      },
                      padding: MySpacing.xy(12, 8),
                      color: contentTheme.primary,
                      borderRadiusAll: 8,
                      child: MyText.labelMedium("Guardar", color: contentTheme.onPrimary, fontWeight: 600),
                    ),
                  ],
                )
              ],
            ),
          ),
          _PatientGraphs(controller: controller,),
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



  Widget commonTextField({
    String? title, String? hintText, bool readOnly = false,
    String? Function(String?)? validator, Widget? prefixIcon,
    void Function()? onTap, TextEditingController? teController,
    bool integer = false, bool floatingPoint = false, int? length}) {
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
        ),
      ],
    );
  }
}



class _LineDescriptor {
  const _LineDescriptor(this.name, this.values, this.color1, {this.color2, this.splitUpDownData = false, this.barCutOffY});

  final String name;
  final List<double?> values;
  final Color color1;
  final Color? color2;
  final bool splitUpDownData;
  final double? barCutOffY;
}

class _GoalLineDescriptor {
  const _GoalLineDescriptor(this.height, this.label, {this.color = Colors.red, this.alignment = Alignment.topRight});

  final double height;
  final String label;
  final Color color;
  final Alignment alignment;
}


class _BarGroupDescriptor {
  const _BarGroupDescriptor(this.name, this.values, this.color);

  final String name;
  final List<({double? toY, double? fromY})> values;
  final Color color;
}


class _CalendarDayDescriptor {
  const _CalendarDayDescriptor(this.date, {this.emotionalState, this.medication, this.exercise});

  final DateTime date;
  final EmotionalState? emotionalState;
  final bool? medication;
  final bool? exercise;
}


DateTime _getMiddleDateTime(DateTime t1, DateTime t2) {
  return t1.add(t1.difference(t2));
}


class _PatientGraphs extends StatefulWidget {
  const _PatientGraphs({super.key, required this.controller});

  final DoctorPatientDetailController controller;

  @override
  State<_PatientGraphs> createState() => _PatientGraphsState();
}

class _PatientGraphsState extends State<_PatientGraphs> with UIMixin {
  @override
  Widget build(BuildContext context) {
    final dateSteps = List<DateTime>.generate(
      widget.controller.timePeriodDays,
          (i) {
        return widget.controller.minDate.add(Duration(days: i + 1));
      },
    );
    final recordHistory = widget.controller.recordHistory;
    //final recordHistoryPair = widget.controller.recordHistoryPair;
    final leftBorderValues = widget.controller.getLeftBorderValues();

    final recordHistoryPair = dateSteps.mapIndexed<(DateTime, DailyRecordModel?)>((i, d) {
      final index = recordHistory.indexWhere((e) => datesAreSameDay(d, e.date));
      return (
      d,
      index == -1 ?
      null :
      //(i == 0 ? leftBorderValues : DailyRecordModel.empty(-1, AuthService.loggedUserData as PatientListModel, d)) :
      recordHistory[index],
      );
    }).toList();

    final bmiThresholds = widget.controller.getBMIThresholds();

    final minValues = widget.controller.getMinValues(leftBorderValues);
    final maxValues = widget.controller.getMaxValues(leftBorderValues);
    final firstValues = widget.controller.getFirstValues();
    final lastValues = widget.controller.getLastValues();
    final weekAverageValues = widget.controller.getWeekAverageValues();
    final averageValues = widget.controller.getAverageValues();

    final weightVerticalGraphPadding = 10.0;
    final waistVerticalGraphPadding = 10.0;
    final sleepTimeVerticalGraphPadding = 1.0;
    final bloodPressureGraphPadding = 10.0;
    final sugarLevelVerticalGraphPadding = 10.0;


    final List<(DateTime, double?)> sleepTimeBars = [];
    final averageCount =
    widget.controller.historyPeriod == TimePeriod.kYear ? 18 :
    (widget.controller.historyPeriod == TimePeriod.k6Months ? 9 :
    (widget.controller.historyPeriod == TimePeriod.k3Months ? 5 :
    (widget.controller.historyPeriod == TimePeriod.kMonth ? 2 : 1)));
    double valueSum = 0.0;
    int sumCount = 0;
    int realSumCount = 0;
    late DateTime firstDate;
    for (final value in recordHistoryPair) {
      if (sumCount == 0) firstDate = value.$1;
      if (value.$2?.sleepTime != null) {
        valueSum += value.$2?.sleepTime?? 0.0;
        ++realSumCount;
      }
      ++sumCount;
      if (sumCount >= averageCount) {
        if (realSumCount == 0) {
          sleepTimeBars.add((_getMiddleDateTime(firstDate, value.$1), null));
          valueSum = 0;
          sumCount = 0;
          continue;
        }
        sleepTimeBars.add((_getMiddleDateTime(firstDate, value.$1), valueSum == 0.0 ? null : valueSum / realSumCount));
        valueSum = 0;
        sumCount = 0;
        realSumCount = 0;
      }
    }
    if (sumCount > 0) {
      sleepTimeBars.add((_getMiddleDateTime(firstDate, recordHistoryPair.last.$1), valueSum == 0.0 ? null : valueSum / sumCount));
    }


    final weightGoalLines = bmiThresholds.mapIndexed<_GoalLineDescriptor?>(
          (i, e) {
        double realHeight = e.$2;
        final lineColor = multiLerpOklab([Colors.amber, Colors.lightGreen, Colors.redAccent], i / 7);
        //Debug.log("Goal line: ${e.$1}", overrideColor: lineColor);
        return _GoalLineDescriptor(
          realHeight,
          e.$1,
          color: lineColor,
        );
      },
    ).where((e) => e != null)
        .map<_GoalLineDescriptor>((e) => e!)
        .toList();
    double? realMinWeight = minValues?.weight;
    double? realMaxWeight = maxValues?.weight;
    double? weightGoal = widget.controller.selectedPatient?.weightGoal;
    Debug.log("weightGoal: $weightGoal", overrideColor: Colors.red);
    if (weightGoal != null) {
      Debug.log("Has weightGoal!", overrideColor: Colors.red);
      weightGoalLines.add(_GoalLineDescriptor(
        weightGoal,
        "Meta de peso",
        color: Colors.purpleAccent,
      ));
      realMinWeight = math.min(realMinWeight?? 999999.9, weightGoal);
      realMaxWeight = math.max(realMaxWeight?? 0.0, weightGoal);
    }

    final waistGoalLines = <_GoalLineDescriptor>[];
    double? realMinWaist = minValues?.waist;
    double? realMaxWaist = maxValues?.waist;
    double? waistGoal = widget.controller.selectedPatient?.waistGoal;
    if (waistGoal != null) {
      waistGoalLines.add(_GoalLineDescriptor(
        waistGoal,
        "Meta de cintura",
        color: Colors.purpleAccent,
      ));
      realMinWaist = math.min(realMinWaist?? 999999.9, waistGoal);
      realMaxWaist = math.max(realMaxWaist?? 0.0, waistGoal);
    }

    final bool hasWeights = realMinWeight != null && realMaxWeight != null && firstValues?.weight != null && lastValues?.weight != null;
    final bool hasWaists = realMinWaist != null && realMaxWaist != null;
    final bool hasSleepTimes = minValues?.sleepTime != null && weekAverageValues?.sleepTime != null && averageValues?.sleepTime != null;
    final bool hasBloodPressures = minValues?.systolicBloodPressure != null && maxValues?.systolicBloodPressure != null &&
                                   minValues?.diastolicBloodPressure != null && maxValues?.diastolicBloodPressure != null;
    final bool hasSugarLevels = minValues?.sugarLevel != null && maxValues?.sugarLevel != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: MySpacing.x(flexSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium(
                "Mis Mediciones",
                fontSize: 18,
                fontWeight: 600,
              ),
              MyBreadcrumb(
                children: [
                  MyBreadcrumbItem(name: 'Tratante'),
                  MyBreadcrumbItem(name: 'Mis mediciones', active: true),
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
                MyText.bodyMedium("Mis Mediciones", fontWeight: 600, muted: true),
                MySpacing.height(20),
                MyText.labelMedium("Periodo de Tiempo", fontWeight: 600, muted: true),
                MySpacing.height(15),
                Wrap(
                  spacing: 16,
                  children: TimePeriod.values.map((period) => InkWell(
                    onTap: () => widget.controller.onPeriodChange(period),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<TimePeriod>(
                          value: period,
                          activeColor: theme.colorScheme.primary,
                          groupValue: widget.controller.historyPeriod,
                          onChanged: (value) => widget.controller.onPeriodChange(value),
                          visualDensity: getCompactDensity,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        MySpacing.width(8),
                        MyText.labelMedium(
                          period.name.capitalize!,
                        ),
                      ],
                    ),
                  ),
                  ).toList(),
                ),
                if (widget.controller.recordHistory.isNotEmpty)
                  MyFlex(
                    contentPadding: false,
                    //spacing: 10,
                    runSpacing: 20,
                    children: [
                      MyFlexItem(
                        sizes: 'lg-6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: hasWeights ? 55.0 : 0.0),
                              child: Center(child: MyText.titleLarge("Peso", fontWeight: 800, muted: true)),
                            ),
                            MySpacing.height(10),
                            if (hasWeights)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 55.0, bottom: 10.0),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    runAlignment: WrapAlignment.center,
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: [
                                      MyText.bodyLarge("Peso inicial: ${firstValues!.weight} Kg", fontWeight: 600,),
                                      MyText.bodyLarge("Peso final: ${lastValues!.weight} Kg", fontWeight: 600,),
                                      MyText.bodyLarge("Diferencia: ${((lastValues.weight! - firstValues.weight!) * 100).round() / 100.0} Kg", fontWeight: 600,),
                                    ],
                                  ),
                                ),
                              ),
                            if (hasWeights)
                              createDataGraph(
                                height: 400.0,
                                minY: realMinWeight - weightVerticalGraphPadding,
                                maxY: realMaxWeight + weightVerticalGraphPadding,
                                minX: 0,
                                maxX: (widget.controller.timePeriodDays - 1).toDouble(),
                                leftSideUnits: (value) {
                                  return MyText.labelMedium("$value Kg");
                                },
                                bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                bottomSideUnits: (value) {
                                  int i = value.toInt();
                                  if (i >= recordHistoryPair.length) return Text("");
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                  );
                                },
                                lines: [
                                  _LineDescriptor(
                                    "Peso",
                                    recordHistoryPair.mapIndexed<double?>((i, e) {
                                      return (i == 0 && e.$2?.weight == null) ? leftBorderValues?.weight : e.$2?.weight;
                                    }).toList(),//..insert(0, leftBorderValues.weight),
                                    Colors.red,
                                    color2: Colors.green,
                                    splitUpDownData: true,
                                  ),
                                ],
                                goalLines: weightGoalLines,
                                getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                showDotInfo: (lineIndex, i) {
                                  if (i >= dateSteps.length) return false;
                                  final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                  return index != -1 && recordHistory[index].weight != null;
                                },
                              )
                            else
                              Center(
                                child: MyText.bodyLarge(
                                  "No hay mediciones de peso registrados.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            MySpacing.height(20),
                            Padding(
                              padding: EdgeInsets.only(left: hasWaists ? 55.0 : 0.0),
                              child: Center(child: MyText.titleLarge("Cintura", fontWeight: 800, muted: true)),
                            ),
                            MySpacing.height(10),
                            if (hasWaists)
                              createDataGraph(
                                height: 400.0,
                                minY: realMinWaist - waistVerticalGraphPadding,
                                maxY: realMaxWaist + waistVerticalGraphPadding,
                                minX: 0,
                                maxX: (widget.controller.timePeriodDays - 1).toDouble(),
                                leftSideUnits: (value) {
                                  return MyText.labelMedium("$value cm");
                                },
                                bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                bottomSideUnits: (value) {
                                  int i = value.toInt();
                                  if (i >= recordHistoryPair.length) return Text("");
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                  );
                                },
                                lines: [
                                  _LineDescriptor(
                                    "Cintura",
                                    recordHistoryPair.mapIndexed<double?>((i, e) {
                                      return (i == 0 && e.$2?.waist == null) ? leftBorderValues?.waist : e.$2?.waist;
                                    }).toList(),
                                    Colors.blue,
                                  ),
                                ],
                                goalLines: waistGoalLines,
                                getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                showDotInfo: (lineIndex, i) {
                                  if (i >= dateSteps.length) return false;
                                  final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                  return index != -1 && recordHistory[index].waist != null;
                                },
                              )
                            else
                              Center(
                                child: MyText.bodyLarge(
                                  "No hay medidas de cintura registradas.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            MySpacing.height(20),
                            Padding(
                              padding: EdgeInsets.only(left: hasSleepTimes ? 55.0 : 0.0),
                              child: Center(child: MyText.titleLarge("Tiempo de Sueño", fontWeight: 800, muted: true)),
                            ),
                            MySpacing.height(10),
                            if (hasSleepTimes)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 55.0, bottom: 10.0),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    runAlignment: WrapAlignment.center,
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: [
                                      MyText.bodyLarge("Promedio semanal: ${weekAverageValues?.sleepTime}h", fontWeight: 600,),
                                      MyText.bodyLarge("Promedio del periodo: ${averageValues?.sleepTime}h", fontWeight: 600,),
                                      MyText.bodyLarge("Días promediados por valor: $averageCount", fontWeight: 600,),
                                    ],
                                  ),
                                ),
                              ),
                            if (hasSleepTimes)
                              createBarGraph(
                                  height: 400.0,
                                  minY: 0,
                                  maxY: 12,
                                  barGroups: sleepTimeBars.map<_BarGroupDescriptor>((e) {
                                    return _BarGroupDescriptor("Tiempo de Sueño", [(toY: e.$2, fromY: null)], Colors.deepPurpleAccent);
                                  }).toList(),
                                  leftSideUnits: (value) {
                                    return MyText.labelMedium("$value h");
                                  },
                                  bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                  bottomSideUnits: (value) {
                                    int i = value.toInt();
                                    if (i >= recordHistoryPair.length) return Text("");
                                    return Transform.rotate(
                                      angle: -0.8,
                                      child: MyText.labelMedium(shortDateFormatter.format(sleepTimeBars[i].$1)),
                                    );
                                  },
                                  getDate: (i) => shortDateFormatter.format(sleepTimeBars[i].$1),
                                  goalLines: [
                                    _GoalLineDescriptor(8, "Sueño normal", color: Colors.green),
                                  ],

                                  getDotInfoText: (index, fromY, toY) {
                                    final date = shortDateFormatter.format(dateSteps[index]);
                                    //return '📅 $date\n📈 ${toY.toStringAsFixed(2)} h';
                                    return '📈 ${toY.toStringAsFixed(2)} h';
                                  }
                              )
                            else
                              Center(
                                child: MyText.bodyLarge(
                                  "No hay mediciones del tiempo de sueño registradas.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                      MyFlexItem(
                        sizes: 'lg-6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: hasBloodPressures ? 55.0 : 0.0),
                              child: Center(child: MyText.titleLarge("Presión Arterial", fontWeight: 800, muted: true)),
                            ),
                            MySpacing.height(10),
                            if (hasBloodPressures)
                              createDataGraph(
                                showLineNames: true,
                                height: 400.0,
                                minY: math.min(minValues!.systolicBloodPressure!, minValues.diastolicBloodPressure!) - bloodPressureGraphPadding,
                                maxY: math.max(maxValues!.systolicBloodPressure!, maxValues.diastolicBloodPressure!) + bloodPressureGraphPadding,
                                minX: 0,
                                maxX: (widget.controller.timePeriodDays - 1).toDouble(),
                                leftSideUnits: (value) {
                                  return MyText.labelMedium("$value mmHg");
                                },
                                bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                bottomSideUnits: (value) {
                                  int i = value.toInt();
                                  if (i >= recordHistoryPair.length) return Text("");
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                  );
                                },
                                lines: [
                                  _LineDescriptor(
                                    "Presión sistólica",
                                    recordHistoryPair.mapIndexed<double?>((i, e) {
                                      return (i == 0 && e.$2?.systolicBloodPressure == null) ? leftBorderValues?.systolicBloodPressure : e.$2?.systolicBloodPressure;
                                    }).toList(),
                                    Colors.pink,
                                  ),
                                  _LineDescriptor(
                                    "Presión diastólica",
                                    recordHistoryPair.mapIndexed<double?>((i, e) {
                                      return (i == 0 && e.$2?.diastolicBloodPressure == null) ? leftBorderValues?.diastolicBloodPressure : e.$2?.diastolicBloodPressure;
                                    }).toList(),
                                    Colors.blue,
                                  ),
                                ],
                                goalLines: [
                                  _GoalLineDescriptor(180.0, "Hipertensión crítica (Sistólica)", color: Colors.pink.shade900),
                                  _GoalLineDescriptor(140.0, "Presión alta etapa 2 (Sistólica)", color: Colors.pink.shade800),
                                  _GoalLineDescriptor(130.0, "Presión alta etapa 1 (Sistólica)", color: Colors.pink.shade600),
                                  _GoalLineDescriptor(120.0, "Presión elevada (Sistólica)", color: Colors.pink.shade400),

                                  _GoalLineDescriptor(120.0, "Hipertensión crítica (Diastólica)", color: Colors.blue.shade900, alignment: Alignment.bottomRight),
                                  _GoalLineDescriptor(90.0, "Presión alta etapa 2 (Diastólica)", color: Colors.blue.shade800),
                                  _GoalLineDescriptor(80.0, "Presión alta etapa 1 (Diastólica)", color: Colors.blue.shade600),
                                ],
                                getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                showDotInfo: (lineIndex, i) {
                                  if (i >= dateSteps.length) return false;
                                  final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                  return index != -1 && (lineIndex == 0 ? recordHistory[index].systolicBloodPressure : recordHistory[index].diastolicBloodPressure) != null;
                                },
                              )
                            else
                              Center(
                                child: MyText.bodyLarge(
                                  "No hay mediciones de presión arterial registradas.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            MySpacing.height(20),
                            Padding(
                              padding: EdgeInsets.only(left: hasSugarLevels ? 55.0 : 0.0),
                              child: Center(child: MyText.titleLarge("Azuca en Sangre", fontWeight: 800, muted: true)),
                            ),
                            MySpacing.height(10),
                            if (hasSugarLevels)
                              createDataGraph(
                                height: 400.0,
                                minY: minValues!.sugarLevel! - sugarLevelVerticalGraphPadding,
                                maxY: maxValues!.sugarLevel! + sugarLevelVerticalGraphPadding,
                                minX: 0,
                                maxX: (widget.controller.timePeriodDays - 1).toDouble(),
                                leftSideUnits: (value) {
                                  return MyText.labelMedium("$value\nmg/dL");
                                },
                                bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                bottomSideUnits: (value) {
                                  int i = value.toInt();
                                  if (i >= recordHistoryPair.length) return Text("");
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                  );
                                },
                                lines: [
                                  _LineDescriptor(
                                    "Nivel de azucar",
                                    recordHistoryPair.mapIndexed<double?>((i, e) {
                                      return (i == 0 && e.$2?.sugarLevel == null) ? leftBorderValues?.sugarLevel : e.$2?.sugarLevel;
                                    }).toList(),
                                    Colors.blue,
                                  ),
                                ],
                                goalLines: [
                                  _GoalLineDescriptor(70, "Bajo Azucar", color: Colors.redAccent),
                                  _GoalLineDescriptor(100, "Alto Azucar (Ayunas)", color: Colors.deepOrangeAccent),
                                  _GoalLineDescriptor(140, "Alto Azucar (Después de comer)", color: Colors.red),
                                ],
                                getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                showDotInfo: (lineIndex, i) {
                                  if (i >= dateSteps.length) return false;
                                  final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                  return index != -1 && recordHistory[index].sugarLevel != null;
                                },
                              )
                            else
                              Center(
                                child: MyText.bodyLarge(
                                  "No hay mediciones del azucar en sangre registradas.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            MySpacing.height(20),
                            Center(child: MyText.titleLarge("Otras mediciones", fontWeight: 800, muted: true)),
                            MySpacing.height(10),
                            createCalendarGraph(
                              height: 400.0,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now(),
                              daysData: widget.controller.completeRecordHistory.map<_CalendarDayDescriptor>((e) =>
                                  _CalendarDayDescriptor(
                                    e.date,
                                    emotionalState: e.emotionalState,
                                    medication: e.medications,
                                    exercise: e.exercise,
                                  ),
                              ).toList(),
                              medicationColor: Colors.deepOrangeAccent,
                              exerciseColor: Colors.lightBlue,
                              emotionalColor1: Color.fromARGB(255, 30, 255, 30),
                              emotionalColor2: Color.fromARGB(255, 255, 30, 30),
                              showDataNames: true,
                              showNumStatistics: true,
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(child: MyText.bodyLarge("Aún no has registrado datos. Comienza hoy para ver tu progreso aquí.", fontWeight: 700,)),
                  ),
                MySpacing.height(20),
              ],
            ),
          ),
        )
      ],
    );
  }


  Widget createDataGraph({
    required double height,
    double minX = 0, double maxX = 6, double minY = 0, double maxY = 100,
    required List<_LineDescriptor> lines, Widget Function(double)? leftSideUnits,
    Widget Function(double)? bottomSideUnits,
    double? leftUnitsInterval, double? bottomUnitsInterval,
    List<_GoalLineDescriptor> goalLines = const [],
    String Function(int)? getDate, bool Function(int, int)? showDotInfo,
    bool showLineNames = false,
  }) {
    return Column(
      children: [
        if (showLineNames && lines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 55.0),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 5.0,
              children: lines.map<Widget>((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.color1,
                      ),
                    ),
                    MySpacing.width(5.0),
                    MyText.labelMedium(e.name, muted: true,),
                  ],
                );
              }).toList(),
            ),
          ),
        if (showLineNames && lines.isNotEmpty)
          MySpacing.height(15.0),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchSpotThreshold: 15.0,
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  //tooltipBgColor: Colors.black.withOpacity(0.7),
                  getTooltipColor: (LineBarSpot spot) {
                    return Colors.black.withAlpha(180);
                  },
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      if (!(showDotInfo?.call(0, index)?? true)) return null;

                      final value = spot.y;
                      final date = getDate?.call(index);// (index >= 0 && index < dates.length) ? dates[index] : 'Unknown';

                      return LineTooltipItem(
                        '${date != null ? '📅 $date\n' : ''}📈 ${value.toStringAsFixed(2)}',
                        TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
                /*getTouchedSpotIndicator: (barData, indicators) {
                  return indicators.map((int index) {
                    /// Indicator Line
                    var lineColor = barData.gradient?.colors.first ?? barData.color;
                    if (barData.dotData.show) {
                      lineColor = _defaultGetDotColor(barData.spots[index], 0, barData);
                    }
                    const lineStrokeWidth = 4.0;
                    final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

                    var dotSize = 10.0;
                    if (barData.dotData.show) {
                      dotSize = 4.0 * 1.8;
                    }

                    final dotData = FlDotData(
                      show: false,
                      checkToShowDot: (_, __) => false,
                      getDotPainter: (spot, percent, bar, index) =>
                          _defaultGetDotPainter(spot, percent, bar, index, size: dotSize),
                    );

                    return TouchedSpotIndicatorData(flLine, dotData);
                  }).toList();
                },*/
              ),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 55,
                    minIncluded: false, maxIncluded: false,
                    interval: leftUnitsInterval,
                    getTitlesWidget: leftSideUnits == null ? defaultGetTitle :
                        (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: leftSideUnits(value),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: bottomUnitsInterval,
                    getTitlesWidget: bottomSideUnits == null ? defaultGetTitle :
                        (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: bottomSideUnits(value),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: lines.mapIndexed<List<LineChartBarData>>((i, e) => _buildLine(i, e, showDotInfo: showDotInfo)).mapMany<LineChartBarData>((e) => e).toList(),
              extraLinesData: ExtraLinesData(
                horizontalLines: goalLines.map<HorizontalLine>((e) => _goalLine(e)).toList(),
              ),
            ),
            curve: Curves.ease,
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> _buildLine(
      int i, _LineDescriptor desc,
      {bool Function(int, int)? showDotInfo,}) {
    if (desc.values.isEmpty || !desc.values.any((e) => e != null)) return [];

    /// TODO: ESTO ES PARA SEPARACIÓN DE LÍNEAS POR COLORES, YA QUE NO LO HAY
    /// NATIVAMENTE EN LA HERRAMIENTA. DESGRACIADAMENTE, SI LO HAGO ASÍ COMO LO
    /// ESTOY HACIENDO, ESTARÍA PONIENDO PUNTOS DOBLES EN CADA EXTREMO DE LAS
    /// LÍNEAS, EN DONDE CAMBIAN DE COLOR, Y ESO HARÍA QUE AL PONER EL MOUSE
    /// ENCIMA DE ELLAS, SE VEAN 2 VALORES EN VEZ DE 1
    List<LineChartBarData> r = [];
    if (desc.splitUpDownData && desc.color2 != null) {
      List<(bool, List<int>)> splitData = [];
      int? lastIndex;
      double? lastValue;
      bool? currentDirection;
      bool? lastCurrentDirection;
      List<int> currentList = [];
      for (int i = 0; i < desc.values.length; ++i) {
        if (desc.values[i] == null) continue;

        lastCurrentDirection = currentDirection;
        if (lastValue != null) {
          currentDirection = (desc.values[i]! - lastValue) >= 0.0;
        }

        if (lastCurrentDirection != null && currentDirection != lastCurrentDirection) {
          //Debug.log("Adding to line [ ${currentList.join(", ")}]");
          splitData.add((lastCurrentDirection, currentList));
          //Debug.log("Current lines [${splitData.map<String>((e) => "${e.$1 ? "up" : "down"} [${e.$2.join(", ")}]").join(", ")}]");
          currentList = [];
          currentList.add(lastIndex!);
        }

        currentList.add(i);
        lastIndex = i;
        lastValue = desc.values[i]!;
      }
      //Debug.log("Adding to line [${currentList.join(", ")}]");
      splitData.add((currentDirection?? true, currentList));

      //Debug.log("Final lines [${splitData.map<String>((e) => "${e.$1 ? "up" : "down"} [${e.$2.join(", ")}]").join(", ")}]");
      for (final split in splitData) {
        r.add(LineChartBarData(
          isCurved: true,
          color: split.$1 ? desc.color1 : desc.color2,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, data) {
              final index = spot.x.toInt();
              return showDotInfo?.call(i, index)?? true;
            },
          ),
          belowBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
          aboveBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
          spots: split.$2.map<FlSpot>((i) => FlSpot(i.toDouble(), desc.values[i]!))
              .toList(),
          //List.generate(desc.values.length, (index) => FlSpot(index.toDouble(), desc.values[index])),
        ));
      }

      return r;
    }

    r.add(LineChartBarData(
      isCurved: true,
      color: desc.color1,
      curveSmoothness: 0.35,
      preventCurveOverShooting: true,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, data) {
          final index = spot.x.toInt();
          /*if (showDotInfo != null) {
            Debug.log("asking to show dot: $index");
          }*/
          return showDotInfo?.call(i, index)?? true;
        },
      ),
      belowBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
      aboveBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
      spots: List<int?>.generate(desc.values.length, (i) => desc.values[i] == null ? null : i)
          .where((i) => i != null)
          .map<FlSpot>((i) => FlSpot(i!.toDouble(), desc.values[i]!))
          .toList(),
      //List.generate(desc.values.length, (index) => FlSpot(index.toDouble(), desc.values[index])),
    ));
    return r;
  }

  HorizontalLine _goalLine(_GoalLineDescriptor desc) {
    return HorizontalLine(
      y: desc.height,
      color: desc.color,
      strokeWidth: 2,
      dashArray: [8, 4],
      label: HorizontalLineLabel(
        show: true,
        alignment: desc.alignment,
        style: TextStyle(color: desc.color, fontWeight: FontWeight.bold),
        labelResolver: (_) => desc.label,
      ),
    );
  }


  Widget createBarGraph({
    required double height, double minY = 0, double maxY = 100,
    required List<_BarGroupDescriptor> barGroups, Widget Function(double)? leftSideUnits,
    Widget Function(double)? bottomSideUnits,
    double? leftUnitsInterval, double? bottomUnitsInterval,
    List<_GoalLineDescriptor> goalLines = const [],
    String Function(int)? getDate, bool Function(int, int)? showDotInfo,
    String Function(int index, double fromY, double toY)? getDotInfoText,
    bool showBarNames = false,}) {
    return Column(
      children: [
        if (showBarNames && barGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 55.0),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 5.0,
              children: barGroups.map<Widget>((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.color,
                      ),
                    ),
                    MySpacing.width(5.0),
                    MyText.labelMedium(e.name, muted: true,),
                  ],
                );
              }).toList(),
            ),
          ),
        if (showBarNames && barGroups.isNotEmpty)
          MySpacing.height(15.0),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              minY: minY,
              maxY: maxY,
              barGroups: barGroups.mapIndexed<BarChartGroupData>((i, e) => _buildBar(i, e.values)).toList(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  //tooltipBgColor: Colors.black.withOpacity(0.7),
                  getTooltipColor: (group) {
                    return Colors.black.withAlpha(180);
                  },
                  getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                    final index = group.x;
                    if (!(showDotInfo?.call(0, index)?? true)) return null;

                    if (getDotInfoText != null) {
                      return BarTooltipItem(
                        getDotInfoText(index, rod.fromY, rod.toY),
                        TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      );
                    }

                    final value = rod.toY;
                    //final value2 = rod.fromY;
                    final date = getDate?.call(index);// (index >= 0 && index < dates.length) ? dates[index] : 'Unknown';

                    return BarTooltipItem(
                      '${date != null ? '📅 $date\n' : ''}📈 ${value.toStringAsFixed(2)}',
                      //'📈 ${value.toStringAsFixed(2)}',
                      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 55,
                    minIncluded: false, maxIncluded: false,
                    interval: leftUnitsInterval,
                    getTitlesWidget: leftSideUnits == null ? defaultGetTitle :
                        (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: leftSideUnits(value),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: bottomUnitsInterval,
                    getTitlesWidget: bottomSideUnits == null ? defaultGetTitle :
                        (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: bottomSideUnits(value),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: goalLines.map<HorizontalLine>((e) => _goalLine(e)).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBar(int x, List<({double? toY, double? fromY})> rodsData) {
    return BarChartGroupData(
      x: x,
      barRods: rodsData.map<BarChartRodData>(
            (e) => BarChartRodData(
          fromY: e.fromY,
          toY: e.toY?? 0.0,
        ),
      ).toList(),
    );
  }


  String _getMonthName(int month) {
    return switch(month) {
      DateTime.january => "Enero",
      DateTime.february => "Febrero",
      DateTime.march => "Marzo",
      DateTime.april => "Abril",
      DateTime.may => "Mayo",
      DateTime.june => "Junio",
      DateTime.july => "Julio",
      DateTime.august => "Agosto",
      DateTime.september => "Septiembre",
      DateTime.october => "Octubre",
      DateTime.november => "Noviembre",
      DateTime.december => "Diciembre",
      int() => "",
    };
  }
  int _getMonthDays(int month, int currentYear) {
    return switch(month) {
      DateTime.january => 31,
      DateTime.february => currentYear % 4 == 0 && (currentYear % 100 != 0 || currentYear % 400 == 0) ? 29 : 28,
      DateTime.march => 31,
      DateTime.april => 30,
      DateTime.may => 31,
      DateTime.june => 30,
      DateTime.july => 31,
      DateTime.august => 31,
      DateTime.september => 30,
      DateTime.october => 31,
      DateTime.november => 30,
      DateTime.december => 31,
      int() => 0,
    };
  }
  String _getWeekDayShortName(int day) {
    return switch(day) {
      DateTime.sunday => "Do",
      DateTime.monday => "Lu",
      DateTime.tuesday => "Ma",
      DateTime.wednesday => "Mi",
      DateTime.thursday => "Ju",
      DateTime.friday => "Vi",
      DateTime.saturday => "Sa",
      int() => "",
    };
  }

  int? _getDayNumber(int r, int w, int firstWeekDay, int maxMonthDays, [bool getExcess = false]) {
    int currentDay = r * 7 + w - firstWeekDay;
    if (!getExcess && (currentDay < 0 || currentDay >= maxMonthDays)) return null;
    return currentDay + 1;
  }

  _CalendarDayDescriptor? _getDay(List<_CalendarDayDescriptor> daysData,
      int currentYear, int currentMonth, int r, int w, int firstWeekDay, int maxMonthDays) {
    final day = _getDayNumber(r, w, firstWeekDay, maxMonthDays);
    if (day == null) return null;

    final checkDate = DateTime(currentYear, currentMonth, day);
    final data = daysData.firstWhere((e) => datesAreSameDay(checkDate, e.date), orElse: () => _CalendarDayDescriptor(checkDate));
    return data;
  }


  Widget createCalendarGraph({
    required double height,
    required DateTime firstDate, required DateTime lastDate,
    required List<_CalendarDayDescriptor> daysData,
    required Color medicationColor, required Color exerciseColor,
    required Color emotionalColor1, required Color emotionalColor2,
    bool showDataNames = false, bool showNumStatistics = false}) {
    if (daysData.isEmpty) return Placeholder(color: Colors.transparent,);

    final firstMonth = daysData.first.date.month;
    final firstDay = daysData.first.date.day;
    final lastMonth = daysData.last.date.month;
    final lastDay = daysData.last.date.day;

    int currentYear = widget.controller.calendarCurrentYear;
    final String year = currentYear.toString();

    int currentMonth = widget.controller.calendarCurrentMonth;
    final String month = _getMonthName(currentMonth);
    final int monthDays = _getMonthDays(currentMonth, currentYear);
    final int firstWeekDay = DateTime(currentYear, currentMonth, 1).weekday - 1;

    final prevMonth = (currentMonth + 10) % 12 + 1;
    final nextMonth = currentMonth % 12 + 1;
    final yearOfThePrevMonth = currentYear - (currentMonth == 1 ? 1 : 0);
    final yearOfTheNextMonth = currentYear + (currentMonth == 12 ? 1 : 0);
    final firstDayOfTheMonth = DateTime(yearOfThePrevMonth, prevMonth, _getMonthDays(prevMonth, yearOfThePrevMonth));
    final lastDayOfTheMonth = DateTime(yearOfTheNextMonth, nextMonth, 1);
    final firstDayOfTheYear = DateTime(currentYear - 1, 12, 31);
    final lastDayOfTheYear = DateTime(currentYear + 1, 1, 1);

    int emotionalMonthSum = 0;
    int emotionalMonthValues = 0;
    int emotionalYearSum = 0;
    int emotionalYearValues = 0;
    for (final e in daysData) {
      if (e.emotionalState == null) continue;
      if (e.date.isAfter(firstDayOfTheMonth) && e.date.isBefore(lastDayOfTheMonth)) {
        emotionalMonthSum += e.emotionalState!.index;
        emotionalMonthValues += 1;
      }
      if (e.date.isAfter(firstDayOfTheYear) && e.date.isBefore(lastDayOfTheYear)) {
        emotionalYearSum += e.emotionalState!.index;
        emotionalYearValues += 1;
      }
    }
    final emotionalMonthAverage = emotionalMonthValues == 0 ? 0.0 : emotionalMonthSum / emotionalMonthValues;
    final Color emotionalMonthColor = emotionalMonthValues == 0 ? Colors.green :
    lerpOklab(emotionalColor1, emotionalColor2, emotionalMonthAverage / (EmotionalState.values.length - 1));
    final emotionalYearAverage = emotionalYearValues == 0 ? 0.0 : emotionalYearSum / emotionalYearValues;
    Color emotionalYearColor = emotionalYearValues == 0 ? Colors.greenAccent :
    lerpOklab(emotionalColor1, emotionalColor2, emotionalYearAverage / (EmotionalState.values.length - 1));
    emotionalYearColor = lerpOklab(emotionalYearColor, Colors.white, 0.25);

    final Color firstColor = Color.fromARGB(255, 250, 250, 250);
    final Color secondColor = Color.fromARGB(255, 235, 235, 235);

    final Color firstWeekColor = lerpOklab(secondColor, Colors.black, 0.25);
    final Color secondWeekColor = lerpOklab(firstColor, Colors.black, 0.25);

    final Color changeMonthLeftColor = currentMonth <= firstMonth ? Color.fromARGB(255, 200, 200, 200) : Colors.white;
    final Color changeMonthRightColor = currentMonth >= lastMonth ? Color.fromARGB(255, 200, 200, 200) : Colors.white;


    int medicationCount = 0;
    int exerciseCount = 0;
    for (final e in daysData) {
      if (e.date.isAfter(firstDayOfTheMonth) && e.date.isBefore(lastDayOfTheMonth)) {
        medicationCount += (e.medication?? false) ? 1 : 0;
        exerciseCount += (e.exercise?? false) ? 1 : 0;
      }
    }
    final monthWeeks = monthDays / 7;
    final medicationWeekAverage = ((medicationCount / monthWeeks) * 100).round() / 100;
    final exerciseWeekAverage = ((exerciseCount / monthWeeks) * 100).round() / 100;


    return Column(
      children: [
        if (showDataNames)
          Column(
            children: [
              Wrap(
                  spacing: 10.0,
                  runSpacing: 5.0,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 15.0,
                          height: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: medicationColor,
                          ),
                        ),
                        MySpacing.width(5.0),
                        MyText.labelMedium("Medicación", muted: true,),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 15.0,
                          height: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: exerciseColor,
                          ),
                        ),
                        MySpacing.width(5.0),
                        MyText.labelMedium("Ejercicio", muted: true,),
                      ],
                    ),
                  ]
              ),
              MySpacing.height(5.0),
              MyText.labelLarge("Estado de ánimo"),
              MySpacing.height(5.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                children: EmotionalState.values.map((e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lerpOklab(emotionalColor1, emotionalColor2, e.index / (EmotionalState.values.length - 1)),
                      ),
                    ),
                    MySpacing.width(5.0),
                    MyText.labelMedium(e.name, muted: true,),
                  ],
                )).toList(),
              ),
              MySpacing.height(15.0),
            ],
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: emotionalYearColor,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Center(child: MyText.titleLarge(year, fontWeight: 700,)),
                    ),
                  ),
                ],
              ),
              Container(
                color: emotionalMonthColor,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MySpacing.width(5.0),
                      BlixCircleButton(
                        radius: 20.0,
                        onTap: () {
                          if (currentMonth <= firstMonth) return;
                          widget.controller.onChangeMonth(-1);
                        },
                        color: Colors.transparent,
                        shadow: false,
                        child: Center(child: Icon(Icons.arrow_left, color: changeMonthLeftColor,),),
                      ),
                      Expanded(
                        child: Center(child: MyText.titleMedium(month, fontWeight: 700,)),
                      ),
                      BlixCircleButton(
                        radius: 20.0,
                        onTap: () {
                          if (currentMonth >= lastMonth) return;
                          widget.controller.onChangeMonth(1);
                        },
                        color: Colors.transparent,
                        shadow: false,
                        child: Center(child: Icon(Icons.arrow_right, color: changeMonthRightColor,),),
                      ),
                      MySpacing.width(5.0),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (int w = 0; w < 7; ++w)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: w % 2 == 0 ? firstWeekColor : secondWeekColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                child: Center(
                                  child: MyText.labelLarge(_getWeekDayShortName(w + 1), fontWeight: 600,),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (int r = 0; r < 6; ++r)
                      Expanded(
                        child: Row(
                          children: [
                            for (int w = 0; w < 7; ++w)
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: r % 2 == w % 2 ? firstColor : secondColor,
                                    borderRadius: r != 5 || (w != 0 && w != 6) ? null :
                                    BorderRadius.only(
                                      bottomLeft: Radius.circular(w == 0 ? 20.0 : 0.0),
                                      bottomRight: Radius.circular(w == 6 ? 20.0 : 0.0),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
                                          child: MyText.labelSmall(_getDayNumber(r, w, firstWeekDay, monthDays)?.toString()?? ""),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.all(3.0),
                                                    decoration: BoxDecoration(
                                                      color: switch(_getDay(daysData, currentYear, currentMonth, r, w, firstWeekDay, monthDays)?.medication) {
                                                        null => Colors.transparent,
                                                        true => medicationColor,
                                                        false => Colors.transparent,
                                                      },
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.all(3.0),
                                                    decoration: BoxDecoration(
                                                      color: switch(_getDay(daysData, currentYear, currentMonth, r, w, firstWeekDay, monthDays)?.exercise) {
                                                        null => Colors.transparent,
                                                        true => exerciseColor,
                                                        false => Colors.transparent,
                                                      },
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.fromLTRB(3.0, 3.0, 22.0, 3.0),
                                                    decoration: BoxDecoration(
                                                      color: switch(_getDay(daysData, currentYear, currentMonth, r, w, firstWeekDay, monthDays)?.emotionalState) {
                                                        null => Colors.transparent,
                                                        EmotionalState.veryGood => emotionalColor1,
                                                        EmotionalState.good => lerpOklab(emotionalColor1, emotionalColor2, 0.25),
                                                        EmotionalState.neutral => lerpOklab(emotionalColor1, emotionalColor2, 0.5),
                                                        EmotionalState.bad => lerpOklab(emotionalColor1, emotionalColor2, 0.75),
                                                        EmotionalState.veryBad => emotionalColor2,
                                                      },
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (currentMonth <= firstMonth && _getDayNumber(r, w, firstWeekDay, monthDays, true)! < firstDay ||
                                          currentMonth >= lastMonth && _getDayNumber(r, w, firstWeekDay, monthDays, true)! > lastDay)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(120, 150, 150, 150),
                                            borderRadius: r != 5 || (w != 0 && w != 6) ? null :
                                            BorderRadius.only(
                                              bottomLeft: Radius.circular(w == 0 ? 20.0 : 0.0),
                                              bottomRight: Radius.circular(w == 6 ? 20.0 : 0.0),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showNumStatistics)
          Column(
            children: [
              MySpacing.height(10.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                alignment: WrapAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Total Medicación: ", fontWeight: 600,),
                      MyText.labelLarge("$medicationCount,", fontWeight: 800,),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Medicación Promedio Semanal: ", fontWeight: 600,),
                      MyText.labelLarge("$medicationWeekAverage,", fontWeight: 800,),
                    ],
                  ),
                ],
              ),
              MySpacing.height(5.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                alignment: WrapAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Total Ejercicio: ", fontWeight: 600,),
                      MyText.labelLarge("$exerciseCount,", fontWeight: 800,),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Ejercicio Promedio Semanal: ", fontWeight: 600,),
                      MyText.labelLarge("$exerciseWeekAverage,", fontWeight: 800,),
                    ],
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}