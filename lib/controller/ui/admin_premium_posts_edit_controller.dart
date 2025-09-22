import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/utils/context_instance.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/premium_post_model.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


class UploadImageInfo {
  const UploadImageInfo(this.name, this.data, this.mime);

  final String name;
  final Uint8List data;
  final String mime;
}

class PostImage {
  PostImage(this.name, this.provider, this.uploadInfo);

  String name;
  final ImageProvider provider;
  final UploadImageInfo? uploadInfo;
}

class AdminPremiumPostEditInstanceData {
  String currentHeader = "";
  String currentSubHeader = "";
  int postIndex = -1;

  PremiumPostModel? selectedPost;

  List<PostImage> images = [];
  List<PostImage> deletedImages = [];
  List<ImageProvider> get imageProviders {
    return images.map((e) => e.provider).toList();
  }
}

class AdminPremiumPostsEditController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;


  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminPremiumPostEditInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );
  Map<int, AdminPremiumPostEditInstanceData> data = {};


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


  void updateInfo(int instanceIndex, [String? header, String? subHeader, int? postIndex]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;
    data[instanceIndex]!.postIndex = postIndex?? data[instanceIndex]!.postIndex;

    final postsList = (await manager.premiumContent
    [PremiumContentTypes.kPosts]
    [data[instanceIndex]!.currentHeader]
    [data[instanceIndex]!.currentSubHeader])
        ?.map<PremiumPostModel>((e) => e as PremiumPostModel).toList();

    if (postsList == null) return;

    data[instanceIndex]!.selectedPost = postsList[data[instanceIndex]!.postIndex];

    basicValidator.getController('title')!.text = data[instanceIndex]!.selectedPost!.tile;
    basicValidator.getController('description')!.text = data[instanceIndex]!.selectedPost!.description;

    data[instanceIndex]!.images = data[instanceIndex]!.selectedPost!.images.map<PostImage>((e) {
      return PostImage(e, CachedNetworkImageProvider(manager.getUploadUrl("images/premium_posts/$e")), null);
    }).toList();

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

  void loadImage(int instanceIndex, String name, Uint8List imgData, String mime) {
    data[instanceIndex]!.images.add(PostImage(name, MemoryImage(imgData), UploadImageInfo(name, imgData, mime)));
    contextInstance.doUpdate(instanceIndex);
  }

  void deleteImage(int instanceIndex, int index) {
    Debug.log("Trying to delete: $index");
    if (index >= data[instanceIndex]!.images.length) return;

    if (data[instanceIndex]!.images[index].uploadInfo == null) {
      data[instanceIndex]!.deletedImages.add(data[instanceIndex]!.images[index]);
    }
    data[instanceIndex]!.images.removeAt(index);
    Debug.log("Removed: $index");

    contextInstance.doUpdate(instanceIndex);
  }


  String getPreviousScreenRoute(int instanceIndex) {
    return '/panel/premium/posts/${data[instanceIndex]!.currentHeader}/${data[instanceIndex]!.currentSubHeader}/list';
  }

  void goListContent(int instanceIndex) {
    Get.toNamed('/panel/premium/posts/${data[instanceIndex]!.currentHeader}/${data[instanceIndex]!.currentSubHeader}/list');
  }

  Future<String?> onEdit(int instanceIndex) async {
    String? validationError;

    final selectedPost = data[instanceIndex]!.selectedPost!;
    final images = data[instanceIndex]!.images;
    final deletedImages = data[instanceIndex]!.deletedImages;

    if (basicValidator.validateForm()) {
      if (images.isEmpty) {
        return "No se puede hacer una publicación sin imágenes.";
      }
      loading = true;
      contextInstance.doUpdate(instanceIndex);
      var errors = await manager.editPremiumPost(
        basicValidator.getData(),
        selectedPost.id,
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

      Debug.log("Uploading new images", overrideColor: Colors.deepOrangeAccent);
      for (final img in images) {
        if (img.uploadInfo == null) {
          Debug.log("Image ${img.name} is not new", overrideColor: Colors.deepOrangeAccent);
          continue;
        }
        Debug.log("Image ${img.name} being uploaded...", overrideColor: Colors.deepOrangeAccent);

        final response = await manager.uploadFile(
          img.uploadInfo!.name, img.uploadInfo!.data,
          MediaType.parse(img.uploadInfo!.mime), "images/premium_posts/",
        );
        if (response.success) {
          Debug.log("Image ${img.name} successfully uploaded", overrideColor: Colors.deepOrangeAccent);
          img.name = response.name;
          await manager.registerPremiumPostImage(response.name.replaceAll('"', ''), selectedPost.id);
        }
        else {
          Debug.log("Image ${img.name} failed to upload", overrideColor: Colors.deepOrangeAccent);
          validationError = "Algunas imágenes no se subieron correctamente";
        }
      }

      data[instanceIndex]!.images = data[instanceIndex]!.images.map(
        (e) => PostImage(
          e.name,
          CachedNetworkImageProvider(manager.getUploadUrl("images/premium_posts/${e.name}")),
          null,
        ),
      ).toList();

      for (final img in deletedImages) {
        final response = await manager.deleteFile(img.name, "images/premium_posts/");
        if (response == null) {
          await manager.deletePremiumPostImage(img.name);
        }
        else {
          validationError = "Algunas imágenes no se eliminaron correctamente";
        }
      }
      data[instanceIndex]!.deletedImages.clear();

      loading = false;
      contextInstance.doUpdate(instanceIndex);
    }
    else {
      validationError = "Hay errores en algunos datos";
    }

    await manager.getPremiumContentSubHeader(
      PremiumContentTypes.kPosts, data[instanceIndex]!.currentHeader, data[instanceIndex]!.currentSubHeader,
    );
    updateInfo(instanceIndex);
    return validationError;
  }
}
