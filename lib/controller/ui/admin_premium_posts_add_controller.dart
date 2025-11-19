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


class _UploadImageInfo {
  const _UploadImageInfo(this.name, this.data, this.mime);

  final String name;
  final Uint8List data;
  final String mime;
}

class _PostImage {
  const _PostImage(this.provider, this.uploadInfo);

  final ImageProvider provider;
  final _UploadImageInfo? uploadInfo;
}

class AdminPremiumPostsAddController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;


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

  bool free = false;

  final List<_PostImage> _images = [];
  final List<_PostImage> _deletedImages = [];
  List<ImageProvider> get imageProviders {
    return _images.map((e) => e.provider).toList();
  }


  @override
  void onInit() {
    basicValidator.addField(
      'title', required: true, label: "Título",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'description', required: true, label: "Descripción",
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
    basicValidator.getController('description')!.text = "";

    _images.clear();
    _deletedImages.clear();

    contextInstance.doUpdate(instanceIndex);
  }


  GlobalKey<FormState> addNewFormKey() {
    formKeys.add(GlobalKey());
    basicValidator.formKey = formKeys.last;
    return basicValidator.formKey;
  }

  void /**/disposeFormKey(GlobalKey<FormState> key) {
    if (formKeys.contains(key)) {
      formKeys.remove(key);
    }
    basicValidator.formKey = formKeys.isNotEmpty ? formKeys.last : GlobalKey();
  }

  void loadImage(int instanceIndex, String name, Uint8List data, String mime) {
    _images.add(_PostImage(MemoryImage(data), _UploadImageInfo(name, data, mime)));
    contextInstance.doUpdate(instanceIndex);
  }

  void deleteImage(int instanceIndex, int index) {
    Debug.log("Trying to delete: $index");
    if (index >= _images.length) return;

    if (_images[index].uploadInfo != null) {
      _deletedImages.add(_images[index]);
    }
    _images.removeAt(index);
    Debug.log("Removed: $index");

    contextInstance.doUpdate(instanceIndex);
  }


  void onFreeCheckboxChange(int instanceIndex, bool newValue) {
    free = newValue;
    contextInstance.doUpdate(instanceIndex);
  }


  String getPreviousScreenRoute() {
    return '/panel/premium/posts/$_currentHeader/$_currentSubHeader/list';
  }


  void goListContent() {
    Get.toNamed('/panel/premium/posts/$_currentHeader/$_currentSubHeader/list');
  }

  Future<String?> onRegister(int instanceIndex) async {
    String? validationError;

    if (basicValidator.validateForm()) {
      if (_images.isEmpty) {
        return "No se puede hacer una publicación sin imágenes.";
      }
      loading = true;
      contextInstance.doUpdate(instanceIndex);
      var registerInfo = await manager.registerPremiumPost(
        basicValidator.getData(), free, _currentHeader, _currentSubHeader,
      );
      if (registerInfo.errors != null) {
        if (registerInfo.errors!.containsKey("server")) {
          validationError = registerInfo.errors!["server"];
          registerInfo.errors!.remove("server");
        }
        if (registerInfo.errors!.isNotEmpty) {
          basicValidator.addErrors(registerInfo.errors!);
          basicValidator.validateForm();
          basicValidator.clearErrors();
          validationError = "Hay errores en algunos datos";
        }
      }

      if (registerInfo.id == null) {
        loading = false;
        contextInstance.doUpdate(instanceIndex);
        return "Hubo un error con el servidor. Intentalo de nuevo más tarde.";
      }

      for (final img in _images) {
        if (img.uploadInfo == null) break;

        final response = await manager.uploadFile(
          img.uploadInfo!.name, img.uploadInfo!.data,
          MediaType.parse(img.uploadInfo!.mime), "images/premium_posts/",
        );
        if (response.success) {
          await manager.registerPremiumPostImage(response.name.replaceAll('"', ''), registerInfo.id!);
        }
        else {
          validationError = "Algunas imágenes no se subieron correctamente";
        }
      }

      loading = false;
      contextInstance.doUpdate(instanceIndex);
    }
    else {
      validationError = "Hay errores en algunos datos";
    }

    await manager.getPremiumContentSubHeader(PremiumContentTypes.kPosts, _currentHeader, _currentSubHeader);
    return validationError;
  }
}
