import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:medicare/controller/ui/patient_dates_list_controller.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
//import 'package:medicare/helpers/widgets/my_key_widget.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:blix_essentials/blix_essentials.dart';


class PatientDatesListScreen extends StatefulWidget {
  const PatientDatesListScreen({super.key});

  @override
  State<PatientDatesListScreen> createState() => _PatientDatesListScreenState();
}

class _PatientDatesListScreenState extends State<PatientDatesListScreen> with UIMixin {
  PatientDatesListController controller = Get.put(PatientDatesListController());

  int instanceIndex = -1;
  bool firstFrame = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.addInstance();
    controller.updateDates(instanceIndex);
  }

  @override
  void dispose() {
    controller.disposeInstance(instanceIndex);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'patient_dates_list_controller',
        builder: (controller) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!firstFrame && controller.updateInstanceIndex != instanceIndex) return;
            firstFrame = false;
            controller.calculateContentWidth(instanceIndex, flexSpacing + 20);
          });

          final contentWidth = controller.getContentWidth(instanceIndex);

          //Debug.log("GetBuilder.builder()", overrideColor: Colors.purple);
          //Debug.log("contentWidth: $contentWidth", overrideColor: Colors.purpleAccent);
          //final screenWidth = MediaQuery.of(context).size.width;
          //final availableSpace = (1541 - (1920 - screenWidth));

          final cardsSpacing = 5.0;
          final cardsMinWidth = 225.0;
          int? cardsMaxCount = contentWidth == null ? null : contentWidth ~/ (cardsMinWidth + cardsSpacing);
          if (cardsMaxCount != null && ((cardsMaxCount + 1) * cardsMinWidth + cardsMaxCount * cardsSpacing) < contentWidth!) {
            cardsMaxCount += 1;
          }
          cardsMaxCount = cardsMaxCount == null ? null : math.min(cardsMaxCount, controller.dates.length);
          //Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.purpleAccent);
          final totalSpacing = cardsMaxCount == null ? null : (cardsMaxCount - 1) * cardsSpacing;
          //Debug.log("totalSpacing: $totalSpacing", overrideColor: Colors.purpleAccent);
          final availableCardSpace = totalSpacing == null ? null : contentWidth! - totalSpacing;
          //Debug.log("availableCardSpace: $availableCardSpace", overrideColor: Colors.purpleAccent);
          final cardsWidth = availableCardSpace == null ? null : availableCardSpace / cardsMaxCount!;
          //Debug.log("cardsWidth: $cardsWidth", overrideColor: Colors.purpleAccent);

          return Column(
            key: controller.getContentKey(instanceIndex),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Container(color: Colors.red, width: controller.contentWidth, height: 10.0,),
              ),*/
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
                        MyBreadcrumbItem(name: 'Tratante'),
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
                      /*MySpacing.height(15),
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
                      ),*/
                      MySpacing.height(20),
                      if (controller.dates.isNotEmpty)
                        Wrap(
                          spacing: cardsSpacing * 0.99,
                          runSpacing: cardsSpacing,
                          children: controller.dates
                              .mapIndexed((index, data) => dateCard(
                            controller.getDoctorName(data),
                            controller.getDateFormatted(data.date),
                            cardsWidth,
                          )).toList(),
                        ),
                      if (controller.dates.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MyText.bodyMedium("No tienes citas agendadas actualmente", fontWeight: 800, muted: true),
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

  Widget dateCard(String doctorName, String date, [double? width]) {
    return MyContainer(
      width: width,
      bordered: true,
      border: Border.all(
        color: Colors.black54,
        width: 1.0,
      ),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      paddingAll: 12.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MyText.titleSmall("Médico: ", fontWeight: 800,),
                ),
              ),
              MySpacing.width(5.0),
              SizedBox(
                width: width == null ? null : width - 91.0, // 60 tile + 5 spacing + 24 padding + 2 border
                child: MyText.bodySmall(doctorName, fontWeight: 600),
              ),
            ],
          ),
          MySpacing.height(10.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MyText.titleSmall("Fecha: ", fontWeight: 800,),
                ),
              ),
              MySpacing.width(5.0),
              SizedBox(
                width: width == null ? null : width - 91.0, // 60 tile + 5 spacing + 24 padding + 2 border
                child: MyText.bodySmall(date, fontWeight: 600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
