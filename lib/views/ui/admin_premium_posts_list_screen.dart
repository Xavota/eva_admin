import 'dart:math' as math;

import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:get/get.dart';

import 'package:medicare/controller/ui/admin_premium_posts_list_controller.dart';
import 'package:medicare/db_manager.dart';
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


class AdminPremiumPostsListScreen extends StatefulWidget {
  const AdminPremiumPostsListScreen({super.key});

  @override
  State<AdminPremiumPostsListScreen> createState() => _AdminPremiumPostsListScreenState();
}

class _AdminPremiumPostsListScreenState extends State<AdminPremiumPostsListScreen> with SingleTickerProviderStateMixin, UIMixin {
  AdminPremiumPostsListController controller = Get.put(AdminPremiumPostsListController());

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
                  controller.goAddPost(instanceIndex);
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
          final screenSize = MediaQuery.of(context).size;

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
            contentWidth, minWidth: 300.0, spacing: 1.0, hardLimitMin: 3,
          );

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
                                      return;
                                    }

                                    await controller.manager.getPremiumContent();
                                    controller.updateInfo(instanceIndex);
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
                          //MyText.bodyMedium("Posts", fontWeight: 600, muted: true),
                          Center(child: MyText.titleLarge(controller.data[instanceIndex]!.currentSubHeader, fontWeight: 700, muted: true)),
                          MySpacing.height(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(70, (i) => MyContainer(width: 2.5, height: 2.5, shape: BoxShape.circle, color: Colors.black54,)),
                          ),
                          MySpacing.height(15),
                          if (controller.data[instanceIndex]!.content != null && controller.data[instanceIndex]!.content!.isNotEmpty)
                            Wrap(
                              spacing: 1.0,
                              runSpacing: 1.0,
                              children: controller.data[instanceIndex]!.providers.mapIndexed<Widget>((i, e) =>
                                _contentThumbnailCard(
                                  cardsWidth, e[0].$2,
                                  onTap: () {
                                    final screenType = MyScreenMedia.getTypeFromWidth(screenSize.width);
                                    if (screenType.isMobile || screenType.isTablet) {
                                      _showPostMobile(
                                        i,
                                        screenWidth: screenSize.width, screenHeight: screenSize.height,
                                        minHorizontalMargin: 80.0, minVerticalMargin: 40.0,
                                        minCarouselWidth: 300.0, minCarouselHeight: 300.0,
                                        titleHeight: 50.0, maxDetailsHeight: 200.0, maxWidth: 500.0,
                                      );
                                    }
                                    else {
                                      _showPostWide(
                                        i,
                                        screenWidth: screenSize.width, screenHeight: screenSize.height,
                                        minHorizontalMargin: 80.0, minVerticalMargin: 40.0,
                                        minCarouselWidth: 500.0, minCarouselHeight: 500.0,
                                        minDetailsWidth: 350.0, maxDetailsWidth: 450.0,
                                      );
                                    }
                                  },
                                ),
                              ).toList(),
                            )
                          else
                            MyText.bodySmall("No hay posts aún en esta categoría, agrega post para que los pacientes premium puedan ver."),
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

  void _showPostWide(int postIndex, {
    required double screenWidth, required double screenHeight,
    required double minHorizontalMargin, required double minVerticalMargin,
    required double minCarouselWidth, required double minCarouselHeight,
    required double minDetailsWidth, required double maxDetailsWidth,
  }) {
    controller.resetCarousel(instanceIndex);
    controller.onChangeSelectedPost(instanceIndex, postIndex);

    showDialog(
      context: context,
      builder: (context) {
        return PostDialogWide(
          controller: controller, instanceIndex: instanceIndex,
          postIndex: postIndex,
          screenWidth: screenWidth, screenHeight: screenHeight,
          minHorizontalMargin: minHorizontalMargin, minVerticalMargin: minVerticalMargin,
          minCarouselWidth: minCarouselWidth, minCarouselHeight: minCarouselHeight,
          minDetailsWidth: minDetailsWidth, maxDetailsWidth: maxDetailsWidth,
          contentTheme: contentTheme, colorScheme: colorScheme,
        );
      },
    );
  }

  void _showPostMobile(int postIndex, {
    required double screenWidth, required double screenHeight,
    required double minHorizontalMargin, required double minVerticalMargin,
    required double minCarouselWidth, required double minCarouselHeight,
    required double titleHeight, required double maxDetailsHeight, required double maxWidth,
  }) {
    controller.resetCarousel(instanceIndex);
    controller.onChangeSelectedPost(instanceIndex, postIndex);

    showDialog(
      context: context,
      builder: (context) {
        return PostDialogMobile(
          controller: controller, instanceIndex: instanceIndex,
          screenWidth: screenWidth, screenHeight: screenHeight,
          minHorizontalMargin: minHorizontalMargin, minVerticalMargin: minVerticalMargin,
          minCarouselWidth: minCarouselWidth, minCarouselHeight: minCarouselHeight,
          titleHeight: titleHeight, maxDetailsHeight: maxDetailsHeight,
          maxWidth: maxWidth,
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
                            child: MyText.labelLarge('Borra Categoría',
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
                        "Todos los posts e imágenes en esta serán eliminados igualmente.",
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

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}


class PostDialogWide extends StatefulWidget {
  const PostDialogWide({super.key,
    required this.controller, required this.instanceIndex,
    required this.postIndex,
    required this.screenWidth, required this.screenHeight,
    required this.minHorizontalMargin, required this.minVerticalMargin,
    required this.minCarouselWidth, required this.minCarouselHeight,
    required this.minDetailsWidth, required this.maxDetailsWidth,
    required this.contentTheme, required this.colorScheme,
  });

  final AdminPremiumPostsListController controller;
  final int instanceIndex;
  final int postIndex;

  final double screenWidth;
  final double screenHeight;
  final double minHorizontalMargin;
  final double minVerticalMargin;
  final double minCarouselWidth;
  final double minCarouselHeight;
  final double minDetailsWidth;
  final double maxDetailsWidth;

  final ContentTheme contentTheme;
  final ColorScheme colorScheme;

  @override
  State<PostDialogWide> createState() => _PostDialogWideState();
}

class _PostDialogWideState extends State<PostDialogWide> {
  @override
  Widget build(BuildContext context) {
    final maxPostWidth = widget.screenWidth - widget.minHorizontalMargin * 2.0;
    final maxPostHeight = widget.screenHeight - widget.minVerticalMargin * 2.0;

    final postIndex = widget.controller.data[widget.instanceIndex]!.selectedPost;

    final postImages = widget.controller.data[widget.instanceIndex]!.providers[postIndex];
    final imagesAspect = postImages.fold<double>(0.0, (v, e) => math.max(v, (e.$1?? 1.0)));

    double carouselWidth = 0.0;
    double carouselHeight = 0.0;
    double detailsWidth = 0.0;
    double postWidth = 0.0;
    double postHeight = 0.0;

    carouselWidth = maxPostWidth - widget.minDetailsWidth;
    carouselHeight = carouselWidth / imagesAspect;
    if (carouselHeight > maxPostHeight) {
      carouselHeight = maxPostHeight;
      carouselWidth = carouselHeight * imagesAspect;
      if (carouselWidth < widget.minCarouselWidth) {
        carouselWidth = widget.minCarouselWidth;
      }
    }
    else if (carouselHeight < widget.minCarouselHeight) {
      carouselHeight = widget.minCarouselHeight;
    }
    detailsWidth = math.min(maxPostWidth - carouselWidth, widget.maxDetailsWidth);

    postWidth = carouselWidth + detailsWidth;
    postHeight = carouselHeight;

    double realHMargin = (widget.screenWidth - postWidth) * 0.5;
    double realVMargin = (widget.screenHeight - postHeight) * 0.5;


    String postTile = widget.controller.data[widget.instanceIndex]!.content?[postIndex].tile?? "";
    String postDescription = widget.controller.data[widget.instanceIndex]!.content?[postIndex].description?? "";

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
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: _wideLayout(carouselWidth, carouselHeight, detailsWidth, postTile, postDescription),
          ),
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
                  widget.controller.resetCarousel(widget.instanceIndex, true);
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
                  widget.controller.resetCarousel(widget.instanceIndex, true);
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

  Widget _wideLayout(double carouselWidth, double carouselHeight, double detailsWidth, String title, String description) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: carouselWidth,
          child: _simpleCarousel(widget.controller.data[widget.instanceIndex]!.selectedPost, carouselHeight),
        ),
        Column(
          children: [
            SizedBox(
              width: detailsWidth,
              height: carouselHeight - 70.0,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                      child: MyText.titleMedium(title, fontWeight: 700,),
                    ),
                    Divider(indent: 10.0, endIndent: 10.0,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                      child: MyText.bodyMedium(description, fontWeight: 500,),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: detailsWidth,
              height: 70.0,
              child: Column(
                children: [
                  Divider(indent: 10.0, endIndent: 10.0,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyContainer.shadow(
                          height: 30.0,
                          color: widget.contentTheme.danger,
                          borderRadiusAll: 10.0,
                          padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
                          shadowBlurRadius: 3.0,
                          onTap: () {
                            _showDeletePostDialog(() async {
                              final errors = await widget.controller.removePost(widget.instanceIndex, widget.postIndex);
                              if (errors != null) {
                                if (!mounted) return;
                                for (final e in errors.entries) {
                                  if (e.key == "server") {
                                    simpleSnackBar(context, e.value, widget.contentTheme.danger);
                                  }
                                }
                                return;
                              }

                              await widget.controller.manager.getPremiumContentSubHeader(
                                PremiumContentTypes.kPosts,
                                widget.controller.data[widget.instanceIndex]!.currentHeader,
                                widget.controller.data[widget.instanceIndex]!.currentSubHeader,
                              );
                              widget.controller.updateInfo(widget.instanceIndex);

                              Get.back();
                            });
                          },
                          child: Center(
                            child: MyText.labelSmall(
                              "Borrar", fontWeight: 700,
                              color: widget.contentTheme.onDanger,
                            ),
                          ),
                        ),
                        MyContainer.shadow(
                          height: 30.0,
                          color: widget.colorScheme.secondaryContainer,
                          borderRadiusAll: 10.0,
                          padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
                          shadowBlurRadius: 3.0,
                          onTap: () {
                            Get.back();
                            widget.controller.goEditPost(widget.instanceIndex, widget.postIndex);
                          },
                          child: Center(
                            child: MyText.labelSmall(
                              "Editar", fontWeight: 700,
                              color: widget.colorScheme.onSecondaryContainer,
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
      ],
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withAlpha(140),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }

  Widget _simpleCarousel(int postIndex, double height) {
    final postImages = widget.controller.data[widget.instanceIndex]!.providers[postIndex];
    List<Widget> buildPageIndicatorStatic() {
      List<Widget> list = [];
      for (int i = 0; i < postImages.length; i++) {
        list.add(i == widget.controller.data[widget.instanceIndex]!.selectedPostCarousel ? _indicator(true) : _indicator(false));
      }
      return list;
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: height,
          color: Colors.black,
          child: PageView(
            pageSnapping: true,
            scrollBehavior: AppScrollBehavior(),
            physics: ClampingScrollPhysics(),
            controller: widget.controller.data[widget.instanceIndex]!.simplePageController,
            onPageChanged: (value) {
              widget.controller.onChangePostCarousel(widget.instanceIndex, value);
              setState(() {});
            },
            children: postImages.map((e) {
              return MyContainer(
                color: Colors.transparent,
                //borderRadiusAll: 5,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                paddingAll: 0,
                child: Image(image: e.$2, fit: BoxFit.contain),
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.black38,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildPageIndicatorStatic(),
            ),
          ),
        ),
        if (widget.controller.hasPrevImage(widget.instanceIndex))
          Positioned(
            left: 10,
            child: MyContainer.shadow(
              width: 25.0,
              height: 25.0,
              shape: BoxShape.circle,
              color: Colors.white,
              paddingAll: 0.0,
              onTap: () {
                widget.controller.goPrevCarouselImage(widget.instanceIndex, postIndex);
                setState(() {});
              },
              child: Center(
                child: Icon(Icons.arrow_left, color:Colors.black, size: 20.0,),
              ),
            ),
          ),
        if (widget.controller.hasNextImage(widget.instanceIndex, postIndex))
          Positioned(
            right: 10,
            child: MyContainer.shadow(
              width: 25.0,
              height: 25.0,
              shape: BoxShape.circle,
              color: Colors.white,
              paddingAll: 0.0,
              onTap: () {
                widget.controller.goNextCarouselImage(widget.instanceIndex, postIndex);
                setState(() {});
              },
              child: Center(
                child: Icon(Icons.arrow_right, color:Colors.black, size: 20.0,),
              ),
            ),
          ),
      ],
    );
  }


  void _showDeletePostDialog(void Function() onConfirm) {
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
                            child: MyText.labelLarge('Borra Post',
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
                    child: MyText.bodySmall("¿Seguro que quiere borrar este post?\n"
                        "Todas las imágenes en este serán eliminados igualmente.",
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


class PostDialogMobile extends StatefulWidget {
  const PostDialogMobile({super.key,
    required this.controller, required this.instanceIndex,
    required this.screenWidth, required this.screenHeight,
    required this.minHorizontalMargin, required this.minVerticalMargin,
    required this.minCarouselWidth, required this.minCarouselHeight,
    required this.titleHeight, required this.maxDetailsHeight,
    required this.maxWidth,
  });

  final AdminPremiumPostsListController controller;
  final int instanceIndex;

  final double screenWidth;
  final double screenHeight;
  final double minHorizontalMargin;
  final double minVerticalMargin;
  final double minCarouselWidth;
  final double minCarouselHeight;
  final double titleHeight;
  final double maxDetailsHeight;
  final double maxWidth;

  @override
  State<PostDialogMobile> createState() => _PostDialogMobileState();
}

class _PostDialogMobileState extends State<PostDialogMobile> {
  @override
  Widget build(BuildContext context) {
    final maxPostWidth = math.min(widget.screenWidth - widget.minHorizontalMargin * 2.0, widget.maxWidth);
    final maxPostHeight = widget.screenHeight - widget.minVerticalMargin * 2.0;

    final postIndex = widget.controller.data[widget.instanceIndex]!.selectedPost;

    final postImages = widget.controller.data[widget.instanceIndex]!.providers[postIndex];
    final imagesAspect = postImages.fold<double>(0.0, (v, e) => math.max(v, (e.$1?? 1.0)));

    double carouselWidth = 0.0;
    double carouselHeight = 0.0;
    double detailsHeight = 0.0;
    double postWidth = 0.0;
    double postHeight = 0.0;

    carouselHeight = maxPostHeight - widget.titleHeight;
    carouselWidth = carouselHeight * imagesAspect;
    if (carouselWidth > maxPostWidth) {
      carouselWidth = maxPostWidth;
      carouselHeight = carouselWidth / imagesAspect;
      if (carouselHeight < widget.minCarouselHeight) {
        carouselHeight = widget.minCarouselHeight;
      }
    }
    if (carouselWidth < widget.minCarouselWidth) {
      carouselWidth = widget.minCarouselWidth;
    }
    detailsHeight = math.min(maxPostHeight - carouselHeight - widget.titleHeight, widget.maxDetailsHeight);

    postWidth = carouselWidth;
    postHeight = widget.titleHeight + carouselHeight + detailsHeight;

    double realHMargin = (widget.screenWidth - postWidth) * 0.5;
    double realVMargin = (widget.screenHeight - postHeight) * 0.5;


    String postTile = widget.controller.data[widget.instanceIndex]!.content?[postIndex].tile?? "";
    String postDescription = widget.controller.data[widget.instanceIndex]!.content?[postIndex].description?? "";

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
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: _mobileLayout(carouselWidth, carouselHeight, postTile, postDescription),
          ),
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
                  widget.controller.resetCarousel(widget.instanceIndex, true);
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
                  widget.controller.resetCarousel(widget.instanceIndex, true);
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

  Widget _mobileLayout(double carouselWidth, double carouselHeight, String title, String description) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            child: MyText.titleMedium(title, fontWeight: 700,),
          ),
          SizedBox(
            width: carouselWidth,
            child: _simpleCarousel(
              widget.controller.data[widget.instanceIndex]!.selectedPost,
              carouselHeight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            child: MyText.bodyMedium(description, fontWeight: 500,),
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withAlpha(140),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }

  Widget _simpleCarousel(int postIndex, double height) {
    final postImages = widget.controller.data[widget.instanceIndex]!.providers[postIndex];
    List<Widget> buildPageIndicatorStatic() {
      List<Widget> list = [];
      for (int i = 0; i < postImages.length; i++) {
        list.add(i == widget.controller.data[widget.instanceIndex]!.selectedPostCarousel ? _indicator(true) : _indicator(false));
      }
      return list;
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: height,
          color: Colors.black,
          child: PageView(
            pageSnapping: true,
            scrollBehavior: AppScrollBehavior(),
            physics: ClampingScrollPhysics(),
            controller: widget.controller.data[widget.instanceIndex]!.simplePageController,
            onPageChanged: (value) {
              widget.controller.onChangePostCarousel(widget.instanceIndex, value);
              setState(() {});
            },
            children: postImages.map((e) {
              return MyContainer(
                color: Colors.transparent,
                borderRadiusAll: 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                paddingAll: 0,
                child: Image(image: e.$2, fit: BoxFit.contain),
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.black38,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildPageIndicatorStatic(),
            ),
          ),
        ),
        if (widget.controller.hasPrevImage(widget.instanceIndex))
          Positioned(
            left: 10,
            child: MyContainer.shadow(
              width: 25.0,
              height: 25.0,
              shape: BoxShape.circle,
              color: Colors.white,
              paddingAll: 0.0,
              onTap: () {
                widget.controller.goPrevCarouselImage(widget.instanceIndex, postIndex);
                setState(() {});
              },
              child: Center(
                child: Icon(Icons.arrow_left, color:Colors.black, size: 20.0,),
              ),
            ),
          ),
        if (widget.controller.hasNextImage(widget.instanceIndex, postIndex))
          Positioned(
            right: 10,
            child: MyContainer.shadow(
              width: 25.0,
              height: 25.0,
              shape: BoxShape.circle,
              color: Colors.white,
              paddingAll: 0.0,
              onTap: () {
                widget.controller.goNextCarouselImage(widget.instanceIndex, postIndex);
                setState(() {});
              },
              child: Center(
                child: Icon(Icons.arrow_right, color:Colors.black, size: 20.0,),
              ),
            ),
          ),
      ],
    );
  }
}
