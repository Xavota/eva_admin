import 'dart:typed_data';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/premium_book_model.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


class UploadFileInfo {
  const UploadFileInfo(this.name, this.data, this.mime);

  final String name;
  final Uint8List data;
  final String mime;
}

class PostImage {
  PostImage(this.name, this.provider, this.uploadInfo);

  String name;
  final ImageProvider provider;
  final UploadFileInfo? uploadInfo;
}

class AdminPremiumBookEditInstanceData {
  String currentHeader = "";
  String currentSubHeader = "";
  int postIndex = -1;

  final TextEditingController dropZoneTControllerFrontPage = TextEditingController();
  final TextEditingController dropZoneTControllerBook = TextEditingController();

  PremiumBookModel? selectedBook;

  PostImage? frontPage;
  ImageProvider? get frontPageProvider {
    return frontPage?.provider;
  }
  UploadFileInfo? bookFile;
}

class AdminPremiumBooksEditController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminPremiumBookEditInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );
  Map<int, AdminPremiumBookEditInstanceData> data = {};



  @override
  void onInit() {
    basicValidator.addField(
      'title', required: true, label: "Título",
      controller: TextEditingController(),
    );

    super.onInit();
  }


  void updateInfo(int instanceIndex, [String? header, String? subHeader, int? postIndex]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;
    data[instanceIndex]!.postIndex = postIndex?? data[instanceIndex]!.postIndex;

    final postsList = (await manager.premiumContent
    [PremiumContentTypes.kBooks]
    [data[instanceIndex]!.currentHeader]
    [data[instanceIndex]!.currentSubHeader])
        ?.map<PremiumBookModel>((e) => e as PremiumBookModel).toList();

    if (postsList == null) return;

    data[instanceIndex]!.selectedBook = postsList[data[instanceIndex]!.postIndex];

    basicValidator.getController('title')!.text = data[instanceIndex]!.selectedBook!.tile;
    data[instanceIndex]!.dropZoneTControllerFrontPage.text = data[instanceIndex]!.selectedBook!.frontPage;
    data[instanceIndex]!.dropZoneTControllerBook.text = data[instanceIndex]!.selectedBook!.book;

    final frontPageName = data[instanceIndex]!.selectedBook!.frontPage;
    data[instanceIndex]!.frontPage = PostImage(frontPageName, CachedNetworkImageProvider(manager.getUploadUrl("images/premium_books/$frontPageName")), null);

    contextInstance.doUpdate(instanceIndex);
  }


  GlobalKey<FormState> addNewFormKey() {
    formKeys.add(GlobalKey());
    basicValidator.formKey = formKeys.last;
    return basicValidator.formKey;
  }

  void disposeFormKey(GlobalKey<FormState> key) {
    if (formKeys.contains(key)) {
      formKeys.remove(key);
    }
    basicValidator.formKey = formKeys.last;
  }

  void loadFrontPage(int instanceIndex, String name, Uint8List fileData, String mime) {
    data[instanceIndex]!.frontPage = PostImage(name, MemoryImage(fileData), UploadFileInfo(name, fileData, mime));
    contextInstance.doUpdate(instanceIndex);
  }

  void loadBook(int instanceIndex, String name, Uint8List fileData, String mime) {
    data[instanceIndex]!.bookFile = UploadFileInfo(name, fileData, mime);
    contextInstance.doUpdate(instanceIndex);
  }


  String getPreviousScreenRoute(int instanceIndex) {
    return '/panel/premium/books/${data[instanceIndex]!.currentHeader}/${data[instanceIndex]!.currentSubHeader}/list';
  }

  void goListContent(int instanceIndex) {
    Get.toNamed('/panel/premium/books/${data[instanceIndex]!.currentHeader}/${data[instanceIndex]!.currentSubHeader}/list');
  }

  /// TODO: AÚN FALTA CAMBIAR ESTA FUNCIÓN PARA QUE NO SUBA UN LIBRO NUEVO, SINO
  /// QUE EDITE EL ANTERIOR. TIENE QUE VER SI LA IMAGEN Y EL LIBRO QUE SE ESTÁN
  /// SUBIENDO SON NUEVOS O SON LOS QUE YA ESTABA, PARA DETERMINAR SI MANDA A
  /// BORRAR LOS ANTERIORES O NO.
  Future<String?> onEdit(int instanceIndex) async {
    String? validationError;

    if (basicValidator.validateForm()) {
      /*if (data[instanceIndex]!.frontPage == null || data[instanceIndex]!.frontPage!.uploadInfo == null) {
        return "No se puede editar un libro sin portada.";
      }
      if (data[instanceIndex]!.bookFile == null) {
        return "No hay un archivo de libro para subir.";
      }*/

      loading = true;
      contextInstance.doUpdate(instanceIndex);

      String frontPageName = data[instanceIndex]!.selectedBook!.frontPage;
      String bookName = data[instanceIndex]!.selectedBook!.book;

      if (data[instanceIndex]!.frontPage?.uploadInfo != null) {
        manager.deleteFile(frontPageName, "images/premium_books/");

        var frontPageUpload = await manager.uploadFile(
          data[instanceIndex]!.frontPage!.uploadInfo!.name, data[instanceIndex]!.frontPage!.uploadInfo!.data,
          MediaType.parse(data[instanceIndex]!.frontPage!.uploadInfo!.mime), "images/premium_books/",
        );
        if (!frontPageUpload.success) {
          loading = false;
          contextInstance.doUpdate(instanceIndex);
          return "La foto de portada no se subió correctamente";
        }
        frontPageName = frontPageUpload.name.replaceAll('"', '');
      }

      if (data[instanceIndex]!.bookFile != null) {
        manager.deleteFile(bookName, "pdf/premium_books/");

        final bookUpload = await manager.uploadFile(
          data[instanceIndex]!.bookFile!.name, data[instanceIndex]!.bookFile!.data,
          MediaType.parse(data[instanceIndex]!.bookFile!.mime), "pdf/premium_books/",
        );
        if (!bookUpload.success) {
          loading = false;
          contextInstance.doUpdate(instanceIndex);
          return "El pdf del libro no se subió correctamente";
        }
        bookName = bookUpload.name.replaceAll('"', '');
      }

      var errors = await manager.editPremiumBook(
        basicValidator.getData(), data[instanceIndex]!.selectedBook!.id, frontPageName, bookName,
      );
      if (errors != null) {
        if (errors.containsKey("server")) {
          validationError = errors["server"];
          errors.remove("server");
        }
        if (errors.isNotEmpty) {
          basicValidator.addErrors(errors);
          basicValidator.validateForm();
          basicValidator.clearErrors();
          validationError = "Hay errores en algunos datos";
        }
      }

      loading = false;
      contextInstance.doUpdate(instanceIndex);
    }
    else {
      validationError = "Hay errores en algunos datos";
    }

    await manager.getPremiumContentSubHeader(PremiumContentTypes.kBooks, data[instanceIndex]!.currentHeader, data[instanceIndex]!.currentSubHeader);
    return validationError;
  }
}
