import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/controller/ui/doctor_patient_studies_detail_controller.dart';

import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';


class DoctorPatientStudiesDetailScreen extends StatefulWidget {
  const DoctorPatientStudiesDetailScreen({super.key});

  @override
  State<DoctorPatientStudiesDetailScreen> createState() => _DoctorPatientStudiesDetailScreenState();
}

class _DoctorPatientStudiesDetailScreenState extends State<DoctorPatientStudiesDetailScreen> with UIMixin {
  DoctorPatientStudiesDetailController controller = Get.put(DoctorPatientStudiesDetailController());

  int instanceIndex = -1;
  bool firstFrame = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.contextInstance.addInstance();

    final String param1 = Get.parameters['patientIndex']!;
    final int patientIndex = int.parse(param1);
    final String param2 = Get.parameters['index']!;
    final int index = int.parse(param2);
    controller.updateInfo(instanceIndex, patientIndex, index).then((_) {
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
    final screenSize = MediaQuery.of(context).size;

    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'doctor_patient_prescription_detail_controller',
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

          final cardsWidth = contentWidth == null ? null : Utils.getColumnsWidth(
            contentWidth, minWidth: 320.0, spacing: 1.0, hardLimitMax: 3,
          );

          double? titlesSize(double? width, double extraPadding) {
            return width == null ? null : width + extraPadding;
          }

          return Column(
            key: controller.contextInstance.getContentKey(instanceIndex, "global"),
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
                        "Vista de Estudio Médico",
                        fontSize: 18,
                        fontWeight: 600,
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: 'Médico'),
                          MyBreadcrumbItem(name: 'Paciente'),
                          MyBreadcrumbItem(name: 'Vista Estudio', active: true),
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
                  paddingAll: 20,
                  borderRadiusAll: 12,
                  child: Column(
                    key: controller.contextInstance.getContentKey(instanceIndex, "content"),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: MyText.bodyLarge("Estudio Médico", fontWeight: 800, muted: true)),
                        ],
                      ),
                      MySpacing.height(10),
                      if (controller.data[instanceIndex]!.selectedStudy != null)
                        showStudyInfo(cardsWidth, screenSize)
                      else
                        MyText.bodySmall("No hay una estudio seleccionado"),
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

  Widget _contentThumbnailCard(double? width, ImageProvider image, {
    void Function()? onTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: width == null ? null : width * 1.4,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget showStudyInfo(double? cardsWidth, Size screenSize) {
    final data = controller.data[instanceIndex]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(data.selectedStudy!.description),
        MySpacing.height(25.0),

        if (data.selectedStudy!.pdf.isNotEmpty)
          MyContainer(
            onTap: () {
              controller.showPDFPreview(instanceIndex);
            },
            padding: MySpacing.xy(12, 8),
            color: contentTheme.primary,
            borderRadiusAll: 8,
            child: MyText.labelMedium("Ver estudio médico", color: contentTheme.onPrimary, fontWeight: 600),
          )
        else if (data.providers.isNotEmpty)
          Wrap(
            spacing: 1.0,
            runSpacing: 1.0,
            children: data.providers.mapIndexed<Widget>((i, e) =>
                _contentThumbnailCard(
                  cardsWidth, e.$2,
                  onTap: () {
                    _showImage(
                      i,
                      screenWidth: screenSize.width, screenHeight: screenSize.height,
                      minHorizontalMargin: 80.0, minVerticalMargin: 40.0,
                    );
                  },
                ),
            ).toList(),
          )
        else
          MyText.bodySmall("No hay posts aún en esta categoría, agrega post para que los pacientes premium puedan ver."),
      ],
    );
  }

  void _showImage(int imageIndex, {
    required double screenWidth, required double screenHeight,
    required double minHorizontalMargin, required double minVerticalMargin,
  }) {
    controller.onChangeViewedImage(instanceIndex, imageIndex);

    showDialog(
      context: context,
      builder: (context) {
        return ImageDialogWide(
          controller: controller, instanceIndex: instanceIndex,
          screenWidth: screenWidth, screenHeight: screenHeight,
          minHorizontalMargin: minHorizontalMargin, minVerticalMargin: minVerticalMargin,
        );
      },
    );
  }
}


class ImageDialogWide extends StatefulWidget {
  const ImageDialogWide({super.key,
    required this.controller, required this.instanceIndex,
    required this.screenWidth, required this.screenHeight,
    required this.minHorizontalMargin, required this.minVerticalMargin,
  });

  final DoctorPatientStudiesDetailController controller;
  final int instanceIndex;

  final double screenWidth;
  final double screenHeight;
  final double minHorizontalMargin;
  final double minVerticalMargin;

  @override
  State<ImageDialogWide> createState() => _ImageDialogWideState();
}

class _ImageDialogWideState extends State<ImageDialogWide> {
  @override
  Widget build(BuildContext context) {
    final data = widget.controller.data[widget.instanceIndex]!;

    final maxImageWidth = widget.screenWidth - widget.minHorizontalMargin * 2.0;
    final maxImageHeight = widget.screenHeight - widget.minVerticalMargin * 2.0;

    final studyImage = data.providers[data.viewImageIndex];
    final imageAspect = studyImage.$1?? 1.0;

    double imageWidth = maxImageWidth;
    double imageHeight = imageWidth / imageAspect;
    if (imageHeight > maxImageHeight) {
      imageHeight = maxImageHeight;
      imageWidth = imageHeight * imageAspect;
    }

    double realHMargin = (widget.screenWidth - imageWidth) * 0.5;
    double realVMargin = (widget.screenHeight - imageHeight) * 0.5;

    return Dialog(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0.0,
      insetPadding: EdgeInsets.all(0.0),
      insetAnimationCurve: Curves.easeInBack,
      backgroundColor: Colors.transparent,
      insetAnimationDuration: Durations.short1,
      child: Stack(
        children: [
          MyContainer(
            color: Colors.black45,
            onTap: () {Navigator.of(context).pop();},
            paddingAll: 0.0,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(
              realHMargin, realVMargin, realHMargin, realVMargin,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(1.0)),
              image: DecorationImage(image: studyImage.$2, fit: BoxFit.contain),
            ),
          ),
          if (widget.controller.hasPrevImage(widget.instanceIndex))
            Align(
              alignment: Alignment.centerLeft,
              child: MyContainer.shadow(
                width: 35.0,
                height: 35.0,
                margin: EdgeInsets.only(left: 25.0),
                shape: BoxShape.circle,
                color: Colors.white,
                paddingAll: 0.0,
                onTap: () {
                  widget.controller.goPrevImage(widget.instanceIndex);
                  setState(() {});
                },
                child: Center(
                  child: Icon(Icons.chevron_left, color:Colors.black, size: 30.0,),
                ),
              ),
            ),
          if (widget.controller.hasNextImage(widget.instanceIndex))
            Align(
              alignment: Alignment.centerRight,
              child: MyContainer.shadow(
                width: 35.0,
                height: 35.0,
                margin: EdgeInsets.only(right: 25.0),
                shape: BoxShape.circle,
                color: Colors.white,
                paddingAll: 0.0,
                onTap: () {
                  widget.controller.goNextImage(widget.instanceIndex);
                  setState(() {});
                },
                child: Center(
                  child: Icon(Icons.chevron_right, color:Colors.black, size: 30.0,),
                ),
              ),
            ),

          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 20.0, right: 20.0,),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.close, size: 30.0, color: Colors.white,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
