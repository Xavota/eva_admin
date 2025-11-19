import 'dart:math' as math;

import 'package:blix_essentials/blix_essentials.dart';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:medicare/controller/ui/patient_premium_books_list_controller.dart';

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


class PatientPremiumBooksListScreen extends StatefulWidget {
  const PatientPremiumBooksListScreen({super.key});

  @override
  State<PatientPremiumBooksListScreen> createState() => _PatientPremiumBooksListScreenState();
}

class _PatientPremiumBooksListScreenState extends State<PatientPremiumBooksListScreen> with SingleTickerProviderStateMixin, UIMixin {
  PatientPremiumBooksListController controller = Get.put(PatientPremiumBooksListController());

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
      child: GetBuilder(
        init: controller,
        tag: 'patient_premium_content_controller',
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
                          MyText.titleMedium(
                            //"Contenido Premium",
                            controller.data[instanceIndex]!.currentHeader,
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Paciente'),
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
                                    cardsWidth, e.$2, controller.coverUpBook(instanceIndex, i),
                                    onTap: () {
                                      //controller.showBookPreview(instanceIndex, i);
                                      _showBook(i);
                                    },
                                  ),
                                ).toList(),
                              ),
                            )
                          else
                            MyText.bodySmall("No hay libros aún en esta categoría."),
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

  Widget _contentThumbnailCard(double? width, ImageProvider image, bool coverUp, {
    void Function()? onTap
  }) {
    return Stack(
      children: [
        InkWell(
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
        ),
        if (coverUp)
          Container(
            width: width,
            height: width == null ? null : width * 1.4,
            decoration: BoxDecoration(
                color: Colors.black54
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.crown,
                        color: Colors.amber,
                        size: math.min(width == null ? 50.0 : width * 0.2, 100.0),
                      ),
                      MySpacing.width(10.0),
                      Icon(
                        Icons.lock,
                        color: Color.fromARGB(255, 200, 200, 200),
                        size: math.min(width == null ? 50.0 : width * 0.2, 100.0),
                      ),
                    ],
                  ),
                  MySpacing.height(20.0),
                  MyText.bodyLarge("Contacta con tu médico para activar tu suscripción", color: Colors.white, fontWeight: 800, textAlign: TextAlign.center,)
                ],
              ),
            ),
          ),
      ],
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
