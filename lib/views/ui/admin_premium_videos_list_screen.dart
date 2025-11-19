import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:medicare/controller/ui/admin_premium_videos_list_controller.dart';
import 'package:medicare/helpers/theme/admin_theme.dart';

import 'package:medicare/helpers/utils/utils.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/responsive.dart';

import 'package:medicare/views/layout/layout.dart';

import 'package:blix_essentials/blix_essentials.dart';


class AdminPremiumVideosListScreen extends StatefulWidget {
  const AdminPremiumVideosListScreen({super.key});

  @override
  State<AdminPremiumVideosListScreen> createState() => _AdminPremiumVideosListScreenState();
}

class _AdminPremiumVideosListScreenState extends State<AdminPremiumVideosListScreen> with SingleTickerProviderStateMixin, UIMixin {
  AdminPremiumVideosListController controller = Get.put(AdminPremiumVideosListController());

  int instanceIndex = -1;
  bool firstFrame = true;

  @override
  void initState() {
    super.initState();
    instanceIndex = controller.contextInstance.addInstance();

    final String header = Get.parameters['header']!;
    final String subHeader = Get.parameters['subHeader']!;
    controller.updateInfo(instanceIndex, header, subHeader).then((_) {
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
    Debug.log(MyScreenMedia.getTypeFromWidth(MediaQuery.of(context).size.width).name, overrideColor: Colors.purpleAccent);

    final screenSize = MediaQuery.of(context).size;
    final screenType = MyScreenMedia.getTypeFromWidth(screenSize.width);

    return Layout(
      externalChild: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: MyContainer(
                width: 50.0,
                height: 50.0,
                paddingAll: 0.0,
                shape: BoxShape.circle,
                color: ContentThemeColor.primary.color,
                onTap: () {
                  controller.goAddVideo(instanceIndex);
                },
                child: Icon(
                  Icons.add,
                  color: ContentThemeColor.primary.onColor,
                  size: 30.0,
                ),
              ),
            ),
          )
        ],
      ),
      child: GetBuilder(
        init: controller,
        tag: 'admin_premium_content_controller',
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

          double? cardsWidth = contentWidth == null ? null : Utils.getColumnsWidth(
              contentWidth, minWidth: 400.0, spacing: 1.0, hardLimitMax: 3
          );
          final cardsHeight = cardsWidth == null ? null : math.min(cardsWidth * 1.414, 900);
          cardsWidth = cardsHeight == null ? null : cardsHeight / 1.414;

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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyText.titleMedium(
                                //"Contenido Premium",
                                controller.data[instanceIndex]!.currentHeader,
                                fontSize: 18,
                                fontWeight: 600,
                              ),
                              MySpacing.width(15.0),
                              MyContainer.shadow(
                                height: 30.0,
                                color: contentTheme.danger,
                                borderRadiusAll: 10.0,
                                paddingAll: 8.0,
                                shadowBlurRadius: 3.0,
                                onTap: () {
                                  _showDeleteSubHeaderDialog(() async {
                                    final errors = await controller.removeSubHeader(instanceIndex);
                                    if (errors != null) {
                                      if (!context.mounted) return;
                                      for (final e in errors.entries) {
                                        if (e.key == "server") {
                                          simpleSnackBar(context, e.value, contentTheme.danger);
                                        }
                                      }
                                    }
                                  });
                                },
                                child: Center(child: MyText.labelSmall("Borrar categoría", fontWeight: 700, color: contentTheme.onDanger,)),
                              ),
                            ],
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
                          Center(child: MyText.titleLarge(controller.data[instanceIndex]!.currentSubHeader, fontWeight: 700, muted: true)),
                          MySpacing.height(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(70, (i) => MyContainer(width: 2.5, height: 2.5, shape: BoxShape.circle, color: Colors.black54,)),
                          ),
                          MySpacing.height(15),
                          if (controller.data[instanceIndex]!.videos != null && controller.data[instanceIndex]!.videos!.isNotEmpty)
                            Center(
                              child: Wrap(
                                spacing: 1.0,
                                runSpacing: 1.0,
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                children: controller.data[instanceIndex]!.providers.mapIndexed<Widget>((i, e) =>
                                    _contentThumbnailCard(
                                      cardsWidth, e.$2,
                                      onTap: () {
                                        //controller.showVideoPreview(instanceIndex, i);
                                        _showVideo(i, screenSize.height, screenType.isMobile || screenType.isTablet);
                                      },
                                    ),
                                ).toList(),
                              ),
                            )
                          else
                            MyText.bodySmall("No hay videos aún en esta categoría, agrega videos para que los pacientes premium puedan ver."),
                          MySpacing.height(20),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              if (controller.headerNotExist)
                MyContainer(
                  margin: MySpacing.x(flexSpacing),
                  height: globalSize?.height == null ? null : globalSize!.height + 50.0,
                  color: Colors.black38,
                  borderRadiusAll: 0.0,
                  child: Center(
                    child: MyText.bodyLarge("Esta categoría no existe o fue eliminada."
                        "\nIntente con una categoría válida.", color: Colors.white, fontWeight: 800,),
                  ),
                ),
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
        height: width == null ? null : width * 0.5625, // 16:9
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _showVideo(int videoIndex, double screenHeight,  bool mobile) {
    controller.data[instanceIndex]!.selectedVideo = videoIndex;
    showDialog(
      context: context,
      builder: (context) {
        return _VideoDialog(
          controller: controller, instanceIndex: instanceIndex,
          screenHeight: screenHeight, mobile: mobile,
          contentTheme: contentTheme, colorScheme: colorScheme,
        );
      },
    );
  }

  void _showDeleteSubHeaderDialog(void Function() onConfirm) {
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
                            child: MyText.labelLarge('Borrar Categoría',
                                fontWeight: 600)),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            LucideIcons.x,
                            size: 20,
                            color: colorScheme.onSurface.withAlpha(127),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0, thickness: 1),
                  Padding(
                    padding: MySpacing.all(16),
                    child: MyText.bodySmall("¿Seguro que quiere borrar esta categoría?\n"
                        "Todos los videos en esta serán eliminados igualmente.",
                        fontWeight: 600),
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
                            onConfirm();
                            Get.back();
                          },
                          elevation: 0,
                          borderRadiusAll: 8,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor: contentTheme.danger,
                          child: MyText.labelMedium(
                            "Borrar",
                            fontWeight: 600,
                            color: contentTheme.onDanger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class HtmlEmbed extends StatefulWidget {
  final String html;
  const HtmlEmbed(this.html, {super.key});

  @override
  State<HtmlEmbed> createState() => _HtmlEmbedState();
}

class _HtmlEmbedState extends State<HtmlEmbed> {
  @override
  void initState() {
    super.initState();
    Debug.log("init state: embed: ${widget.html}", overrideColor: Colors.red);
  }

  @override
  void dispose() {
    Debug.log("dispose: embed: ${widget.html}", overrideColor: Colors.red);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      widget.html,
      renderMode: RenderMode.column,
      // optional: constrain width/height if your iframes are large
      //factoryBuilder: () => WidgetFactory()..iframeAllowFullscreen = true,
    );
  }
}

class _VideoDialog extends StatefulWidget {
  const _VideoDialog({required this.controller, required this.instanceIndex,
    required this.screenHeight, required this.mobile,
    required this.contentTheme, required this.colorScheme,});

  final AdminPremiumVideosListController controller;
  final int instanceIndex;

  final double screenHeight;
  final bool mobile;

  final ContentTheme contentTheme;
  final ColorScheme colorScheme;

  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  GlobalKey? embedKey;

  HtmlWidget? embedVideo;
  Size? embedSize;

  bool showingPopup = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (embedVideo == null) {
        embedKey = GlobalKey();
        embedVideo = HtmlWidget(
          key: embedKey,
          widget.controller.getVideoEmbed(widget.instanceIndex),
          renderMode: RenderMode.column,
        );
        Debug.log("Created new embed", overrideColor: Colors.green);
        setState(() {});
      }
      else if (embedSize == null) {
        final RenderBox? box = embedKey!.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return;

        embedSize = box.size;
        Debug.log("Calculated embed size", overrideColor: Colors.green);
        setState(() {});
      }
    });

    double maxHeight = widget.screenHeight - (widget.mobile ? 135.0 : 140.0);
    double? embedWidth;

    if (embedSize != null) {
      double embedHeight = embedSize!.height;
      Debug.log("embedHeight: $embedHeight", overrideColor: Colors.green);
      Debug.log("maxHeight: $maxHeight", overrideColor: Colors.green);
      Debug.log("previous size: $embedSize", overrideColor: Colors.green);
      embedWidth = embedSize!.width;
      if (embedHeight > maxHeight) {
        embedWidth = embedWidth * (maxHeight / embedHeight);
        Debug.log("next size: ($embedWidth, $maxHeight)", overrideColor: Colors.green);
      }
    }

    return Dialog(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0.0,
      insetPadding: const EdgeInsets.all(0.0),
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
          Center(
            child: Padding(
              padding: widget.mobile ?
              const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0) :
              const EdgeInsets.fromLTRB(80.0, 20.0, 80.0, 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    width: embedWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: MySpacing.horizontal(10.0),
                          child: SizedBox(
                            height: widget.mobile ? 35.0 : 50.0,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: MyText.titleLarge(
                                      widget.controller.getVideoTitle(widget.instanceIndex),
                                      fontWeight: 800,
                                      fontSize: widget.mobile ? 20.0 : null,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Icon(Icons.close, size: widget.mobile ? 25.0 : 30.0, color: Colors.black,),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (embedVideo != null && !showingPopup) embedVideo!,
                        Padding(
                          padding: MySpacing.horizontal(20.0),
                          child: SizedBox(
                            height: 50.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyContainer.shadow(
                                  height: 30.0,
                                  color: widget.colorScheme.secondaryContainer,
                                  borderRadiusAll: 10.0,
                                  padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
                                  shadowBlurRadius: 3.0,
                                  onTap: () {
                                    Get.back();
                                    widget.controller.goEditVideo(widget.instanceIndex);
                                  },
                                  child: Center(
                                    child: MyText.labelSmall(
                                      "Editar", fontWeight: 700,
                                      color: widget.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                MySpacing.width(40.0),
                                MyContainer.shadow(
                                  height: 30.0,
                                  color: widget.contentTheme.danger,
                                  borderRadiusAll: 10.0,
                                  padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
                                  shadowBlurRadius: 3.0,
                                  onTap: () {
                                    setState(() {
                                      showingPopup = true;
                                    });
                                    _showDeleteVideoDialog(() async {
                                      final errors = await widget.controller.removeVideo(widget.instanceIndex);
                                      if (errors != null) {
                                        if (!context.mounted) return;
                                        for (final e in errors.entries) {
                                          if (e.key == "server") {
                                            simpleSnackBar(context, e.value, widget.contentTheme.danger);
                                          }
                                        }
                                        return;
                                      }

                                      showingPopup = false;
                                      Get.back();
                                    }, () {
                                        setState(() {
                                          showingPopup = false;
                                        });
                                      },
                                    );
                                  },
                                  child: Center(
                                    child: MyText.labelSmall(
                                      "Borrar", fontWeight: 700,
                                      color: widget.contentTheme.onDanger,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.controller.hasPrevPost(widget.instanceIndex))
                          MyContainer.shadow(
                            width: 30.0,
                            height: 30.0,
                            shape: BoxShape.circle,
                            color: Colors.white,
                            paddingAll: 0.0,
                            onTap: () {
                              widget.controller.goPrevPost(widget.instanceIndex);
                              embedVideo = null;
                              embedKey = null;
                              embedSize = null;
                              setState(() {});
                            },
                            child: Center(
                              child: Icon(Icons.chevron_left, color:Colors.black, size: 20.0,),
                            ),
                          )
                        else
                          MySpacing.width(30.0),
                        MySpacing.width(40.0),
                        if (widget.controller.hasNextPost(widget.instanceIndex))
                          MyContainer.shadow(
                            width: 30.0,
                            height: 30.0,
                            shape: BoxShape.circle,
                            color: Colors.white,
                            paddingAll: 0.0,
                            onTap: () {
                              widget.controller.goNextPost(widget.instanceIndex);
                              embedVideo = null;
                              embedKey = null;
                              embedSize = null;
                              setState(() {});
                            },
                            child: Center(
                              child: Icon(Icons.chevron_right, color:Colors.black, size: 20.0,),
                            ),
                          )
                        else
                          MySpacing.width(30.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!widget.mobile)
            Stack(
              children: [
                if (widget.controller.hasPrevPost(widget.instanceIndex))
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
                        widget.controller.goPrevPost(widget.instanceIndex);
                        embedVideo = null;
                        embedKey = null;
                        embedSize = null;
                        setState(() {});
                      },
                      child: Center(
                        child: Icon(Icons.chevron_left, color:Colors.black, size: 30.0,),
                      ),
                    ),
                  ),
                if (widget.controller.hasNextPost(widget.instanceIndex))
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
                        widget.controller.goNextPost(widget.instanceIndex);
                        embedVideo = null;
                        embedKey = null;
                        embedSize = null;
                        setState(() {});
                      },
                      child: Center(
                        child: Icon(Icons.chevron_right, color:Colors.black, size: 30.0,),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _showDeleteVideoDialog(void Function() onConfirm, void Function() onCancel) {
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
                            child: MyText.labelLarge('Borrar Video',
                                fontWeight: 600)),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            LucideIcons.x,
                            size: 20,
                            color: widget.colorScheme.onSurface.withAlpha(127),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0, thickness: 1),
                  Padding(
                    padding: MySpacing.all(16),
                    child: MyText.bodySmall("¿Seguro que quiere borrar este video?",
                        fontWeight: 600),
                  ),
                  Divider(height: 0, thickness: 1),
                  Padding(
                    padding: MySpacing.only(right: 20, bottom: 12, top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyButton(
                          onPressed: () {
                            onCancel();
                            Get.back();
                          },
                          elevation: 0,
                          borderRadiusAll: 8,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor: widget.colorScheme.secondaryContainer,
                          child: MyText.labelMedium(
                            "Cancelar",
                            fontWeight: 600,
                            color: widget.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        MySpacing.width(16),
                        MyButton(
                          onPressed: () {
                            onConfirm();
                            Get.back();
                          },
                          elevation: 0,
                          borderRadiusAll: 8,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor: widget.contentTheme.danger,
                          child: MyText.labelMedium(
                            "Borrar",
                            fontWeight: 600,
                            color: widget.contentTheme.onDanger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}