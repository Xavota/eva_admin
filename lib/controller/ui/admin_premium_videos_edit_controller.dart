import 'dart:typed_data';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/premium_video_model.dart';

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

class AdminPremiumVideoEditInstanceData {
  String currentHeader = "";
  String currentSubHeader = "";
  int videoIndex = -1;

  bool free = false;

  final TextEditingController dropZoneTControllerFrontPage = TextEditingController();

  PremiumVideoModel? selectedVideo;

  PostImage? frontPage;
  ImageProvider? get frontPageProvider {
    return frontPage?.provider;
  }
}

class AdminPremiumVideosEditController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminPremiumVideoEditInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );
  Map<int, AdminPremiumVideoEditInstanceData> data = {};



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


  void updateInfo(int instanceIndex, [String? header, String? subHeader, int? videoIndex]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;
    data[instanceIndex]!.videoIndex = videoIndex?? data[instanceIndex]!.videoIndex;

    final videosList = (await manager.premiumContent
    [PremiumContentTypes.kVideos]
    [data[instanceIndex]!.currentHeader]
    [data[instanceIndex]!.currentSubHeader])
        ?.map<PremiumVideoModel>((e) => e as PremiumVideoModel).toList();

    if (videosList == null) return;

    data[instanceIndex]!.selectedVideo = videosList[data[instanceIndex]!.videoIndex];

    data[instanceIndex]!.free = data[instanceIndex]!.selectedVideo!.free;

    basicValidator.getController('title')!.text = data[instanceIndex]!.selectedVideo!.tile;
    basicValidator.getController('embed')!.text = data[instanceIndex]!.selectedVideo!.embed;
    data[instanceIndex]!.dropZoneTControllerFrontPage.text = data[instanceIndex]!.selectedVideo!.frontPage;

    final frontPageName = data[instanceIndex]!.selectedVideo!.frontPage;
    data[instanceIndex]!.frontPage = PostImage(frontPageName, CachedNetworkImageProvider(manager.getUploadUrl("images/premium_videos/$frontPageName")), null);

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
    data[instanceIndex]!.frontPage = PostImage(name, MemoryImage(fileData), UploadFileInfo(name, fileData, mime));
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

  Future<String?> onEdit(int instanceIndex) async {
    String? validationError;

    if (basicValidator.validateForm()) {
      /*if (data[instanceIndex]!.frontPage == null || data[instanceIndex]!.frontPage!.uploadInfo == null) {
        return "No se puede editar un video sin portada.";
      }*/

      loading = true;
      contextInstance.doUpdate(instanceIndex);

      String frontPageName = data[instanceIndex]!.selectedVideo!.frontPage;

      if (data[instanceIndex]!.frontPage?.uploadInfo != null) {
        final deleteErrors = await manager.deleteFile(frontPageName, "images/premium_videos/");
        if (deleteErrors != null) {
          return "Hubo un error con el servidor, intenta de nuevo más tarde.";
        }

        var frontPageUpload = await manager.uploadFile(
          data[instanceIndex]!.frontPage!.uploadInfo!.name, data[instanceIndex]!.frontPage!.uploadInfo!.data,
          MediaType.parse(data[instanceIndex]!.frontPage!.uploadInfo!.mime), "images/premium_videos/",
        );
        if (!frontPageUpload.success) {
          loading = false;
          contextInstance.doUpdate(instanceIndex);
          return "La foto de portada no se subió correctamente";
        }
        frontPageName = frontPageUpload.name.replaceAll('"', '');
      }

      var errors = await manager.editPremiumVideo(
        basicValidator.getData(), data[instanceIndex]!.selectedVideo!.id, data[instanceIndex]!.free, frontPageName,
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

    await manager.getPremiumContentSubHeader(PremiumContentTypes.kVideos, data[instanceIndex]!.currentHeader, data[instanceIndex]!.currentSubHeader);
    return validationError;
  }
}
