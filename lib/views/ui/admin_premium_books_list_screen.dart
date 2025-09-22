import 'dart:math' as math;

import 'package:blix_essentials/blix_essentials.dart';

import 'package:flutter/material.dart';

import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:medicare/controller/ui/admin_premium_books_list_controller.dart';
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


class AdminPremiumBooksListScreen extends StatefulWidget {
  const AdminPremiumBooksListScreen({super.key});

  @override
  State<AdminPremiumBooksListScreen> createState() => _AdminPremiumBooksListScreenState();
}

class _AdminPremiumBooksListScreenState extends State<AdminPremiumBooksListScreen> with SingleTickerProviderStateMixin, UIMixin {
  AdminPremiumBooksListController controller = Get.put(AdminPremiumBooksListController());

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
                  controller.goAddBook(instanceIndex);
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
            contentWidth, minWidth: 500.0, spacing: 1.0, hardLimitMax: 2
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
                          if (controller.data[instanceIndex]!.books != null && controller.data[instanceIndex]!.books!.isNotEmpty)
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
                                      //controller.showBookPreview(instanceIndex, i);
                                      _showBook(i);
                                    },
                                  ),
                                ).toList(),
                              ),
                            )
                          else
                            MyText.bodySmall("No hay libros aún en esta categoría, agrega libros para que los tratantes premium puedan ver."),
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

  void _showBook(int bookIndex) {
    showDialog(
      context: context,
      builder: (context) {
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
              Container(
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: MySpacing.horizontal(10.0),
                      child: SizedBox(
                        height: 50.0,
                        child: Row(
                          children: [
                            Expanded(child: Center(child: MyText.titleLarge(controller.getBookTitle(instanceIndex, bookIndex), fontWeight: 800,))),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.close, size: 30.0, color: Colors.black,),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: NicePdfViewer(uri: Uri.parse(controller.getBookName(instanceIndex, bookIndex)),),
                    ),
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
                              color: colorScheme.secondaryContainer,
                              borderRadiusAll: 10.0,
                              padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
                              shadowBlurRadius: 3.0,
                              onTap: () {
                                Get.back();
                                controller.goEditBook(instanceIndex, bookIndex);
                              },
                              child: Center(
                                child: MyText.labelSmall(
                                  "Editar", fontWeight: 700,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            MySpacing.width(40.0),
                            MyContainer.shadow(
                              height: 30.0,
                              color: contentTheme.danger,
                              borderRadiusAll: 10.0,
                              padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
                              shadowBlurRadius: 3.0,
                              onTap: () {
                                _showDeleteBookDialog(() async {
                                  final errors = await controller.removeBook(instanceIndex, bookIndex);
                                  if (errors != null) {
                                    if (!context.mounted) return;
                                    for (final e in errors.entries) {
                                      if (e.key == "server") {
                                        simpleSnackBar(context, e.value, contentTheme.danger);
                                      }
                                    }
                                    return;
                                  }

                                  Get.back();
                                });
                              },
                              child: Center(
                                child: MyText.labelSmall(
                                  "Borrar", fontWeight: 700,
                                  color: contentTheme.onDanger,
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
                        "Todos los libros en esta serán eliminados igualmente.",
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

  void _showDeleteBookDialog(void Function() onConfirm) {
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
                            child: MyText.labelLarge('Borra Libro',
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
                    child: MyText.bodySmall("¿Seguro que quiere borrar este libro?",
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


class NicePdfViewer extends StatefulWidget {
  const NicePdfViewer({super.key, required this.uri});
  final Uri uri;

  @override
  State<NicePdfViewer> createState() => _NicePdfViewerState();
}

class _NicePdfViewerState extends State<NicePdfViewer> {
  final _controller = PdfViewerController();
  final _pageEdit = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final p = _controller.pageNumber ?? 1;
      if (_pageEdit.text != '$p') _pageEdit.text = '$p';
      setState(() {}); // refresh overlays (page/slider state)
    });
  }

  Future<void> _jumpTo(int p) async {
    final total = _controller.pageCount;
    if (total == 0) return;
    final clamped = p.clamp(1, total);
    await _controller.goToPage(pageNumber: clamped);
  }

  @override
  Widget build(BuildContext context) {
    return PdfViewer.uri(
      widget.uri,
      controller: _controller,
      params: PdfViewerParams(
        enableKeyboardNavigation: true,
        scrollByMouseWheel: 0.4,
        textSelectionParams: PdfTextSelectionParams(enabled: false),
        viewerOverlayBuilder: (context, size, handleLinkTap) {
          final total = _controller.pageCount;
          final current = _controller.pageNumber ?? 1;

          return <Widget>[
            Stack(
              children: [
                // Top bar: prev | [page box] / total | next
                Positioned(
                  bottom: 10,
                  left: 28,
                  right: 28, // leave space for right scroll thumb
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                                  tooltip: 'Previous page',
                                  onPressed: () => _jumpTo(current - 1),
                                ),
                                SizedBox(
                                  width: 72,
                                  child: TextField(
                                    controller: _pageEdit,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      hintText: '1',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      fillColor: Colors.white12,
                                      filled: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (txt) {
                                      final parsed = int.tryParse(txt);
                                      if (parsed != null) _jumpTo(parsed);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('/ $total', style: const TextStyle(color: Colors.white)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                                  tooltip: 'Next page',
                                  onPressed: () => _jumpTo(current + 1),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Fit page',
                            icon: const Icon(Icons.fit_screen, color: Colors.white),
                            onPressed: () async {
                              final m = _controller.calcMatrixForFit(
                                pageNumber: _controller.pageNumber ?? 1,
                              );
                              if (m != null) await _controller.goTo(m);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right-side scroll thumb (built-in pdfrx widget)
                PdfViewerScrollThumb(
                  controller: _controller,
                  orientation: ScrollbarOrientation.right,
                  // You can style the thumb:
                  thumbBuilder: (ctx, thumbSize, pageNumber, controller) {
                    return Container(
                      width: thumbSize.width,
                      height: thumbSize.height,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pageNumber?.toString() ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ];
        },
      ),
    );
  }
}
