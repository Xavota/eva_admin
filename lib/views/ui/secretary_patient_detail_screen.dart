import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

//import 'package:medicare/images.dart';
import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
//import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
//import 'package:medicare/helpers/widgets/my_flex.dart';
//import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/helpers/widgets/my_form.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:medicare/controller/ui/secretary_patient_detail_controller.dart';
import 'package:medicare/model/patient_list_model.dart';


class SecretaryPatientDetailScreen extends StatefulWidget {
  const SecretaryPatientDetailScreen({super.key});

  @override
  State<SecretaryPatientDetailScreen> createState() => _SecretaryPatientDetailScreenState();
}

class _SecretaryPatientDetailScreenState extends State<SecretaryPatientDetailScreen> with UIMixin {
  SecretaryPatientDetailController controller = Get.put(SecretaryPatientDetailController());


  @override
  void initState() {
    super.initState();

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
              /*MySpacing.height(10),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: pdfViewer(),
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
          MyText.bodyMedium("Detalles", fontWeight: 600, muted: true),
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
          MySpacing.height(20),
          details("Inicia", controller.subscriptionStarts == null ? "-" : dateFormatter.format(controller.subscriptionStarts!)),
          MySpacing.height(20),
          details("Termina", controller.subscriptionEnds == null ? "-" : dateFormatter.format(controller.subscriptionEnds!)),
          MySpacing.height(20),
          Row(
            children: [
              MyContainer(
                onTap: () {
                  _showActivateSubDialog(() => controller.updatePatientInfo(controller.patientIndex));
                },
                padding: MySpacing.xy(12, 8),
                borderRadiusAll: 8,
                color: contentTheme.primary,
                child: MyText.labelSmall("Activar Suscripción", fontWeight: 600, color: contentTheme.onPrimary),
              ),
              if ((controller.subscriptionStatus?? SubscriptionStatus.kNotActive) != SubscriptionStatus.kNotActive)
                MySpacing.width(10),
              if ((controller.subscriptionStatus?? SubscriptionStatus.kNotActive) != SubscriptionStatus.kNotActive)
                MyContainer(
                  onTap: () {
                    _showCancelAlert(() {
                      controller.cancelSubscription().then((validationError) {
                        if (validationError != null) {
                          if (!mounted) return;
                          simpleSnackBar(context, validationError, contentTheme.danger);
                        }
                        else {
                          controller.updatePatientInfo(controller.patientIndex);
                          if (!mounted) return;
                          simpleSnackBar(context, "Suscripción cancelada con éxito", contentTheme.success);
                        }
                      });
                    });
                  },
                  padding: MySpacing.xy(12, 8),
                  borderRadiusAll: 8,
                  color: contentTheme.danger,
                  child: MyText.labelSmall("Cancelar Suscripción", fontWeight: 600, color: contentTheme.onPrimary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showActivateSubDialog(void Function() success) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.0),
            child: ActivateSubWidget(controller: controller, success: success),
          ),
        );
      },
    );
  }

  void _showCancelAlert(void Function() onContinue) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: MySpacing.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: MyText.labelLarge(
                          'Advertencia', fontWeight: 600,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          LucideIcons.x,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 0, thickness: 1),
                Padding(
                  padding: MySpacing.all(16),
                  child: MyText.bodySmall(controller.cancelAlertText, fontWeight: 600),
                ),
                Divider(height: 0, thickness: 1),
                Padding(
                  padding: MySpacing.only(right: 20, bottom: 12, top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyButton(
                        onPressed: () => Get.back(),
                        elevation: 0,
                        borderRadiusAll: 8,
                        padding: MySpacing.xy(20, 16),
                        backgroundColor: colorScheme.secondaryContainer,
                        child: MyText.labelMedium(
                          "Cancelar",
                          fontWeight: 600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      MySpacing.width(16),
                      MyButton(
                        onPressed: () {
                          Get.back();
                          onContinue();
                        },
                        elevation: 0,
                        borderRadiusAll: 8,
                        padding: MySpacing.xy(20, 16),
                        backgroundColor: colorScheme.primary,
                        child: MyText.labelMedium(
                          "Continuar",
                          fontWeight: 600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /*Widget pdfViewer() {
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
            onFileSelected: controller.loadPDFFile,
            onError: (error) {
              if (error == "type") {
                simpleSnackBar(context, "El archivo no es un PDF", contentTheme.danger);
              }
              else if (error == "size") {
                simpleSnackBar(context, "El archivo pesa más de 10MB", contentTheme.danger);
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
  }*/
}


class ActivateSubWidget extends StatefulWidget {
  const ActivateSubWidget({super.key, required this.controller, required this.success});

  final SecretaryPatientDetailController controller;
  final void Function() success;

  @override
  State<ActivateSubWidget> createState() => _ActivateSubWidgetState();
}

class _ActivateSubWidgetState extends State<ActivateSubWidget> with UIMixin {
  @override
  Widget build(BuildContext context) {
    final finalDate = widget.controller.getFinalSubDate();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: MySpacing.all(16),
          child: MyText.labelLarge('Activar Suscripción', fontWeight: 600),
        ),
        Divider(height: 0, thickness: 1),

        Padding(
          padding: MySpacing.all(16),
          child: MyForm(
            addNewFormKey: widget.controller.addNewFormKey,
            disposeFormKey: widget.controller.disposeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonTextField(
                  title: "Fecha de Inicio",
                  hintText: "Selecciona una fecha",
                  validator: widget.controller.basicValidator.getValidation("startDate"),
                  teController: widget.controller.basicValidator.getController("startDate"),
                  prefixIcon: Icon(LucideIcons.calendar, size: 16),
                  onTap: widget.controller.pickStartDate,
                  readOnly: true,
                ),
                MySpacing.height(20),
                MyText.labelMedium("Duración", fontWeight: 600, muted: true),
                MySpacing.height(8),
                DropdownButtonFormField<TimeType>(
                  value: widget.controller.subDurationType,
                  dropdownColor: contentTheme.background,
                  isDense: true,
                  style: MyTextStyle.bodySmall(),
                  items: TimeType.values
                      .map((category) => DropdownMenuItem<TimeType>(
                    value: category,
                    child: MyText.bodySmall(category.name.capitalize!),
                  )).toList(),
                  icon: Icon(LucideIcons.chevron_down, size: 20),
                  decoration: InputDecoration(
                    hintText: "Selecciona duración",
                    hintStyle: MyTextStyle.bodySmall(xMuted: true),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: MySpacing.all(12),
                    isCollapsed: true,
                    isDense: true,
                    prefixIcon: Icon(LucideIcons.circle_plus, size: 16),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  onChanged: (value) {
                    widget.controller.changeDurationType(value);
                    setState(() {});
                  },
                ),
                if (widget.controller.subDurationType == TimeType.kCustom)
                  MySpacing.height(10),
                if (widget.controller.subDurationType == TimeType.kCustom)
                  InputDecorator(
                    decoration: InputDecoration(
                      errorText: widget.controller.basicValidator.getError('duration'),
                    ),
                    child: Wrap(
                      children: [
                        SizedBox(
                          width: 100.0,
                          child: commonTextField(
                            title: "Días",
                            hintText: "Días",
                            validator: widget.controller.basicValidator.getValidation("durationDays"),
                            teController: widget.controller.basicValidator.getController("durationDays"),
                            integer: true, length: 2,
                            onChange: (_) {
                              final daysText = widget.controller.basicValidator.getController("durationDays")!.text;
                              final monthsText = widget.controller.basicValidator.getController("durationMonths")!.text;
                              final yearsText = widget.controller.basicValidator.getController("durationYears")!.text;
                              final days = int.parse(daysText.isNotEmpty ? daysText : "0");
                              final months = int.parse(monthsText.isNotEmpty ? monthsText : "0");
                              final years = int.parse(yearsText.isNotEmpty ? yearsText : "0");
                              widget.controller.changeCustomDuration(
                                days, months, years,
                              );
                              setState(() {});
                            },
                          ),
                        ),
                        MySpacing.width(10),
                        SizedBox(
                          width: 100.0,
                          child: commonTextField(
                            title: "Meses",
                            hintText: "Meses",
                            validator: widget.controller.basicValidator.getValidation("durationMonths"),
                            teController: widget.controller.basicValidator.getController("durationMonths"),
                            integer: true, length: 2,
                            onChange: (_) {
                              final daysText = widget.controller.basicValidator.getController("durationDays")!.text;
                              final monthsText = widget.controller.basicValidator.getController("durationMonths")!.text;
                              final yearsText = widget.controller.basicValidator.getController("durationYears")!.text;
                              final days = int.parse(daysText.isNotEmpty ? daysText : "0");
                              final months = int.parse(monthsText.isNotEmpty ? monthsText : "0");
                              final years = int.parse(yearsText.isNotEmpty ? yearsText : "0");
                              widget.controller.changeCustomDuration(
                                days, months, years,
                              );
                              setState(() {});
                            },
                          ),
                        ),
                        MySpacing.width(10),
                        SizedBox(
                          width: 100.0,
                          child: commonTextField(
                            title: "Años",
                            hintText: "Años",
                            validator: widget.controller.basicValidator.getValidation("durationYears"),
                            teController: widget.controller.basicValidator.getController("durationYears"),
                            integer: true, length: 2,
                            onChange: (_) {
                              final daysText = widget.controller.basicValidator.getController("durationDays")!.text;
                              final monthsText = widget.controller.basicValidator.getController("durationMonths")!.text;
                              final yearsText = widget.controller.basicValidator.getController("durationYears")!.text;
                              final days = int.parse(daysText.isNotEmpty ? daysText : "0");
                              final months = int.parse(monthsText.isNotEmpty ? monthsText : "0");
                              final years = int.parse(yearsText.isNotEmpty ? yearsText : "0");
                              widget.controller.changeCustomDuration(
                                days, months, years,
                              );
                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                MySpacing.height(20),
                MyText.bodyMedium("Fecha Final: ${finalDate != null ? dateFormatter.format(finalDate) : "-"}", fontWeight: 600,)
              ],
            ),
          ),
        ),

        Divider(height: 0, thickness: 1),
        Padding(
          padding: MySpacing.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyButton(
                onPressed: () => Get.back(),
                elevation: 0,
                borderRadiusAll: 8,
                padding: MySpacing.xy(20, 16),
                backgroundColor: colorScheme.secondaryContainer,
                child: MyText.labelMedium(
                  "Cancelar",
                  fontWeight: 600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              MySpacing.width(16),
              MyButton(
                onPressed: () {
                  widget.controller.activateSubscription().then((validationError) {
                    if (validationError != null) {
                      if (!context.mounted) return;
                      simpleSnackBar(context, validationError, contentTheme.danger);
                      setState(() {});
                    }
                    else {
                      widget.success.call();
                      if (!context.mounted) return;
                      simpleSnackBar(context, "Suscripción activada con éxito", contentTheme.success);
                      Get.back();
                    }
                  });
                },
                elevation: 0,
                borderRadiusAll: 8,
                padding: MySpacing.xy(20, 16),
                backgroundColor: colorScheme.primary,
                child: MyText.labelMedium(
                  "Activar",
                  fontWeight: 600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
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
