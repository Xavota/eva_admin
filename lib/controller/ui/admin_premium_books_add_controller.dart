import 'dart:typed_data';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


class _UploadFileInfo {
  const _UploadFileInfo(this.name, this.data, this.mime);

  final String name;
  final Uint8List data;
  final String mime;
}

class _PostImage {
  const _PostImage(this.provider, this.uploadInfo);

  final ImageProvider provider;
  final _UploadFileInfo? uploadInfo;
}

class AdminPremiumBooksAddController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  final TextEditingController dropZoneTControllerFrontPage = TextEditingController();
  final TextEditingController dropZoneTControllerBook = TextEditingController();


  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );

  double? getCardsWidth(int instanceIndex, {
    double cardsMinWidth = 300.0, double cardsSpacing = 1.0,
    int? hardLimitMin, int? hardLimitMax, int? listLength
  }) {
    final contentWidth = contextInstance.getContentWidth(instanceIndex, "global");

    int? cardsMaxCount = contentWidth == null ? null : contentWidth ~/ (cardsMinWidth + cardsSpacing);
    if (cardsMaxCount != null && ((cardsMaxCount + 1) * cardsMinWidth + cardsMaxCount * cardsSpacing) < contentWidth!) {
      cardsMaxCount += 1;
    }
    //Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.green);

    if (listLength != null) {
      cardsMaxCount = cardsMaxCount == null ? null : math.min(cardsMaxCount, listLength);
    }
    //Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.green);
    if (hardLimitMax != null) {
      cardsMaxCount = cardsMaxCount == null ? null : math.min(cardsMaxCount, hardLimitMax);
    }
    //Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.green);
    if (hardLimitMin != null) {
      cardsMaxCount = cardsMaxCount == null ? null : math.max(cardsMaxCount, hardLimitMin);
    }
    //Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.green);
    cardsMaxCount = cardsMaxCount == null ? null : math.max(cardsMaxCount, 1); // Min 1
    //Debug.log("cardsMaxCount: $cardsMaxCount", overrideColor: Colors.green);
    //Debug.log("", overrideColor: Colors.green);

    final totalSpacing = cardsMaxCount == null ? null : (cardsMaxCount - 1) * cardsSpacing;
    final availableCardSpace = totalSpacing == null ? null : contentWidth! - totalSpacing;
    return availableCardSpace == null ? null : availableCardSpace / cardsMaxCount!;
  }


  String _currentHeader = "";
  String _currentSubHeader = "";

  _PostImage? _frontPage;
  ImageProvider? get frontPageProvider {
    return _frontPage?.provider;
  }
  _UploadFileInfo? _bookFile;



  @override
  void onInit() {
    basicValidator.addField(
      'title', required: true, label: "Título",
      controller: TextEditingController(),
    );

    super.onInit();
  }


  void updateInfo(String header, String subHeader) {
    _currentHeader = header;
    _currentSubHeader = subHeader;
  }


  void clearForm(int instanceIndex) {
    basicValidator.getController('title')!.text = "";

    _frontPage = null;
    _bookFile = null;

    dropZoneTControllerFrontPage.text = "";
    dropZoneTControllerBook.text = "";

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

  void loadFrontPage(int instanceIndex, String name, Uint8List data, String mime) {
    _frontPage = _PostImage(MemoryImage(data), _UploadFileInfo(name, data, mime));
    contextInstance.doUpdate(instanceIndex);
  }

  void loadBook(int instanceIndex, String name, Uint8List data, String mime) {
    _bookFile = _UploadFileInfo(name, data, mime);
    contextInstance.doUpdate(instanceIndex);
  }


  String getPreviousScreenRoute() {
    return '/panel/premium/books/$_currentHeader/$_currentSubHeader/list';
  }

  void goListContent() {
    Get.toNamed('/panel/premium/books/$_currentHeader/$_currentSubHeader/list');
  }

  Future<String?> onRegister(int instanceIndex) async {
    String? validationError;

    if (basicValidator.validateForm()) {
      if (_frontPage == null || _frontPage!.uploadInfo == null) {
        return "No se puede publicar un libro sin portada.";
      }
      if (_bookFile == null) {
        return "No hay un archivo de libro para subir.";
      }

      loading = true;
      contextInstance.doUpdate(instanceIndex);

      var frontPageUpload = await manager.uploadFile(
        _frontPage!.uploadInfo!.name, _frontPage!.uploadInfo!.data,
        MediaType.parse(_frontPage!.uploadInfo!.mime), "images/premium_books/",
      );
      if (!frontPageUpload.success) {
        loading = false;
        contextInstance.doUpdate(instanceIndex);
        return "La foto de portada no se subió correctamente";
      }

      final bookUpload = await manager.uploadFile(
        _bookFile!.name, _bookFile!.data,
        MediaType.parse(_bookFile!.mime), "pdf/premium_books/",
      );
      if (!bookUpload.success) {
        loading = false;
        contextInstance.doUpdate(instanceIndex);
        return "El pdf del libro no se subió correctamente";
      }

      var errors = await manager.registerPremiumBook(
        basicValidator.getData(), _currentHeader, _currentSubHeader, frontPageUpload.name.replaceAll('"', ''), bookUpload.name.replaceAll('"', '')
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

    await manager.getPremiumContentSubHeader(PremiumContentTypes.kBooks, _currentHeader, _currentSubHeader);
    return validationError;
  }
}
