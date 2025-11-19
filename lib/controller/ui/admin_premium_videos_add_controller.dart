import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


class UploadFileInfo {
  const UploadFileInfo(this.name, this.data, this.mime);

  final String name;
  final Uint8List data;
  final String mime;
}

class PostImage {
  const PostImage(this.provider, this.uploadInfo);

  final ImageProvider provider;
  final UploadFileInfo? uploadInfo;
}

class AdminPremiumVideosAddInstanceData {
  final TextEditingController dropZoneTControllerFrontPage = TextEditingController();

  String currentHeader = "";
  String currentSubHeader = "";

  bool free = false;

  PostImage? frontPage;
  ImageProvider? get frontPageProvider {
    return frontPage?.provider;
  }
}

class AdminPremiumVideosAddController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminPremiumVideosAddInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );

  Map<int, AdminPremiumVideosAddInstanceData> data = {};


  @override
  void onInit() {
    basicValidator.addField(
      'title', required: true, label: "Título",
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'embed', required: true, label: "Código de inserción",
      controller: TextEditingController(),
    );

    super.onInit();
  }


  void updateInfo(int instanceIndex, [String? header, String? subHeader]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;
  }


  void clearForm(int instanceIndex) {
    basicValidator.getController('title')!.text = "";
    basicValidator.getController('embed')!.text = "";

    data[instanceIndex]!.frontPage = null;

    data[instanceIndex]!.dropZoneTControllerFrontPage.text = "";

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


  void loadFrontPage(int instanceIndex, String name, Uint8List fileData, String mime) {
    data[instanceIndex]!.frontPage = PostImage(
      MemoryImage(fileData), UploadFileInfo(name, fileData, mime),
    );
    contextInstance.doUpdate(instanceIndex);
  }


  void onFreeCheckboxChange(int instanceIndex, bool newValue) {
    data[instanceIndex]!.free = newValue;
    contextInstance.doUpdate(instanceIndex);
  }


  String getPreviousScreenRoute(int instanceIndex) {
    return '/panel/premium/videos/${data[instanceIndex]!.currentHeader}/${data[instanceIndex]!.currentSubHeader}/list';
  }

  void goListContent(int instanceIndex) {
    Get.toNamed('/panel/premium/videos/${data[instanceIndex]!.currentHeader}/${data[instanceIndex]!.currentSubHeader}/list');
  }

  Future<String?> onRegister(int instanceIndex) async {
    String? validationError;

    if (basicValidator.validateForm()) {
      if (data[instanceIndex]!.frontPage?.uploadInfo == null) {
        return "No se puede publicar un video sin portada.";
      }

      loading = true;
      contextInstance.doUpdate(instanceIndex);

      var frontPageUpload = await manager.uploadFile(
        data[instanceIndex]!.frontPage!.uploadInfo!.name, data[instanceIndex]!.frontPage!.uploadInfo!.data,
        MediaType.parse(data[instanceIndex]!.frontPage!.uploadInfo!.mime), "images/premium_videos/",
      );
      if (!frontPageUpload.success) {
        loading = false;
        contextInstance.doUpdate(instanceIndex);
        return "La foto de portada no se subió correctamente";
      }

      var errors = await manager.registerPremiumVideo(
        basicValidator.getData(), data[instanceIndex]!.free,
        data[instanceIndex]!.currentHeader,
        data[instanceIndex]!.currentSubHeader,
        frontPageUpload.name.replaceAll('"', ''),
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

    await manager.getPremiumContentSubHeader(
      PremiumContentTypes.kVideos,
      data[instanceIndex]!.currentHeader, data[instanceIndex]!.currentSubHeader,
    );
    return validationError;
  }
}
