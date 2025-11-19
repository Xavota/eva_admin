import 'dart:async';

import 'package:blix_essentials/blix_essentials.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/premium_book_model.dart';

import 'package:medicare/db_manager.dart';

class PatientPremiumBooksListInstanceData {
  List<PremiumBookModel>? books;
  List<(double?, ImageProvider)> providers = [];
  List<Completer<double>> providersCompleter = [];
  String currentHeader = "";
  String currentSubHeader = "";

  bool patientIsPremium = false;
}

class PatientPremiumBooksListController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = PatientPremiumBooksListInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );


  Map<int, PatientPremiumBooksListInstanceData> data = {};
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

    if (AuthService.loggedUserData != null && AuthService.loggedUserData is PatientListModel) {
      final loggedInPatient = AuthService.loggedUserData as PatientListModel;
      final status = await manager.getPatientSubStatus(loggedInPatient.userNumber);
      data[instanceIndex]!.patientIsPremium = status?.$1 == SubscriptionStatus.kActive;
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


  String getBookTitle(int instanceIndex, int bookIndex) {
    return data[instanceIndex]!.books![bookIndex].tile;
  }

  String getBookName(int instanceIndex, int bookIndex) {
    return manager.getUploadUrl("pdf/premium_books/${data[instanceIndex]!.books![bookIndex].book}");
  }


  bool coverUpBook(int instanceIndex, int bookIndex) {
    return !data[instanceIndex]!.books![bookIndex].free && !data[instanceIndex]!.patientIsPremium;
  }
}
