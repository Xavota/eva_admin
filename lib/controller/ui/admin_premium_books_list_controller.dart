import 'dart:math' as math;
import 'dart:async';

import 'package:blix_essentials/blix_essentials.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/premium_book_model.dart';

import 'package:medicare/db_manager.dart';

class AdminPremiumBooksListInstanceData {
  List<PremiumBookModel>? books;
  List<(double?, ImageProvider)> providers = [];
  List<Completer<double>> providersCompleter = [];
  String currentHeader = "";
  String currentSubHeader = "";
}

class AdminPremiumBooksListController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminPremiumBooksListInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );


  Map<int, AdminPremiumBooksListInstanceData> data = {};
  bool headerNotExist = false;


  Future<void> updateInfo(int instanceIndex, [String? header, String? subHeader]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;
    data[instanceIndex]!.books =
    (await manager.premiumContent[PremiumContentTypes.kBooks]
                                [data[instanceIndex]!.currentHeader]
                                [data[instanceIndex]!.currentSubHeader])
        ?.map<PremiumBookModel>((e) => e as PremiumBookModel).toList();
    Debug.log("content[instanceIndex]: ${data[instanceIndex]!.books}", overrideColor: Colors.red);
    headerNotExist = false;
    if (data[instanceIndex]!.books == null) {
      headerNotExist = true;
      contextInstance.doUpdate(instanceIndex);
      return;
    }

    data[instanceIndex]!.providersCompleter = [];
    data[instanceIndex]!.providers = [];
    for (int b = 0; b < data[instanceIndex]!.books!.length; ++b) {
      int bookIndex = b;
      data[instanceIndex]!.providersCompleter.add(Completer()..future.then((aspect) {
        final provider = data[instanceIndex]!.providers[bookIndex].$2;
        data[instanceIndex]!.providers[bookIndex] = (aspect, provider);
      }));


      final book = data[instanceIndex]!.books![b];

      final image = CachedNetworkImageProvider(
          manager.getUploadUrl("images/premium_books/${book.frontPage}"));

      image
          .resolve(ImageConfiguration())
          .addListener(
        ImageStreamListener(
              (ImageInfo info, bool _) {
            data[instanceIndex]!.providersCompleter[bookIndex]
                .complete(info.image.width / info.image.height);
          },
        ),
      );

      data[instanceIndex]!.providers.add((null, image));
    }

    Future.wait(
      data[instanceIndex]!.providersCompleter
          .map<Future<dynamic>>(
        (e) => e.future,
      ),
    ).then((_) {
      contextInstance.doUpdate(instanceIndex);
    });

    contextInstance.doUpdate(instanceIndex);

    Debug.log("Books length: ${data[instanceIndex]!.books!.length}");
  }

  void goAddBook(int instanceIndex) {
    Get.toNamed('/panel/premium/books/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentHeader)}/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentSubHeader)}/add');
  }

  void goEditBook(int instanceIndex, int bookIndex) {
    Get.toNamed('/panel/premium/books/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentHeader)}/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentSubHeader)}/'
        '$bookIndex/edit');
  }

  Future<Map<String, String>?> removeSubHeader(int instanceIndex) async {
    final errors = await manager.deletePremiumContentHeader(data[instanceIndex]!.currentSubHeader, data[instanceIndex]!.currentHeader);
    if (errors != null) return errors;

    await manager.getPremiumContent();
    await updateInfo(instanceIndex);

    return null;
  }

  Future<Map<String, String>?> removeBook(int instanceIndex, int bookIndex) async {
    final errors = await manager.deletePremiumBook(data[instanceIndex]!.books![bookIndex].id);
    if (errors != null) return errors;

    await manager.getPremiumContentSubHeader(
      PremiumContentTypes.kBooks,
      data[instanceIndex]!.currentHeader,
      data[instanceIndex]!.currentSubHeader,
    );
    await updateInfo(instanceIndex);

    return null;
  }


  String getBookTitle(int instanceIndex, int bookIndex) {
    return data[instanceIndex]!.books![bookIndex].tile;
  }

  String getBookName(int instanceIndex, int bookIndex) {
    return manager.getUploadUrl("pdf/premium_books/${data[instanceIndex]!.books![bookIndex].book}");
  }
}
