import 'dart:math' as math;
import 'dart:async';

import 'package:blix_essentials/blix_essentials.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/premium_video_model.dart';

import 'package:medicare/db_manager.dart';

class AdminPremiumVideosListInstanceData {
  List<PremiumVideoModel>? content;
  List<List<(double?, ImageProvider)>> providers = [];
  List<List<Completer<double>>> providersCompleter = [];
  String currentHeader = "";
  String currentSubHeader = "";

  int selectedPost = 0;
  int selectedPostCarousel = 0;
  final PageController simplePageController = PageController(initialPage: 0);
}

class AdminPremiumVideosListController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminPremiumVideosListInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );


  Map<int, AdminPremiumVideosListInstanceData> data = {};
  bool headerNotExist = false;


  Future<void> updateInfo(int instanceIndex, [String? header, String? subHeader]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;
    data[instanceIndex]!.content =
    (await manager.premiumContent[PremiumContentTypes.kVideos]
                                [data[instanceIndex]!.currentHeader]
                                [data[instanceIndex]!.currentSubHeader])
        ?.map<PremiumVideoModel>((e) => e as PremiumVideoModel).toList();
    Debug.log("content[instanceIndex]: ${data[instanceIndex]!.content}", overrideColor: Colors.red);
    headerNotExist = false;
    if (data[instanceIndex]!.content == null) {
      headerNotExist = true;
      contextInstance.doUpdate(instanceIndex);
      return;
    }

    data[instanceIndex]!.providersCompleter = [];
    data[instanceIndex]!.providers = [];
    for (int p = 0; p < data[instanceIndex]!.content!.length; ++p) {
      final post = data[instanceIndex]!.content![p];
      data[instanceIndex]!.providersCompleter.add(
        List.generate(
          post.images.length,
              (i) => Completer()..future.then((aspect) {
                final provider = data[instanceIndex]!.providers[p][i].$2;
                data[instanceIndex]!.providers[p][i] = (aspect, provider);
              }),
        ),
      );
      data[instanceIndex]!.providers.add(post.images.mapIndexed<(double?, ImageProvider)>((i, e) {
        final image = CachedNetworkImageProvider(
            manager.getUploadUrl("images/premium_posts/$e"));

        image
            .resolve(ImageConfiguration())
            .addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) {
              data[instanceIndex]!.providersCompleter[p][i]
                  .complete(info.image.width / info.image.height);
            },
          ),
        );

        return (null, image);
      }).toList());
    }

    Future.wait(
      data[instanceIndex]!.providersCompleter
          .fold<List<Future<dynamic>>>(
        [], (i, e) => i..addAll(e.map((e) => e.future)),
      ),
    ).then((_) {
      //final aspects = data[instanceIndex]!.providers.fold<List<double?>>([], (i, e) => i..addAll(e.map((f) => f.$1)));
      /*for (var a in aspects) {
        Debug.log("Aspect: $a", overrideColor: Colors.deepOrange);
      }*/
      contextInstance.doUpdate(instanceIndex);
    });

    contextInstance.doUpdate(instanceIndex);
  }

  void goAddPost(int instanceIndex) {
    Get.toNamed('/panel/premium/posts/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentHeader)}/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentSubHeader)}/add');
  }

  void goEditPost(int instanceIndex, int postIndex) {
    Get.toNamed('/panel/premium/posts/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentHeader)}/'
        '${Uri.encodeComponent(data[instanceIndex]!.currentSubHeader)}/'
        '$postIndex/edit');
  }

  Future<Map<String, String>?> removeSubHeader(int instanceIndex) {
    return manager.deletePremiumContentHeader(data[instanceIndex]!.currentSubHeader, data[instanceIndex]!.currentHeader);
  }

  Future<Map<String, String>?> removePost(int instanceIndex, int postIndex) {
    return manager.deletePremiumPost(data[instanceIndex]!.content![postIndex].id);
  }


  void onChangeSelectedPost(int instanceIndex, int newPost) {
    data[instanceIndex]!.selectedPost = newPost;
    contextInstance.doUpdate(instanceIndex);
  }

  void goPrevPost(int instanceIndex) {
    data[instanceIndex]!.selectedPost = math.max(data[instanceIndex]!.selectedPost - 1,  0);
    contextInstance.doUpdate(instanceIndex);
  }

  void goNextPost(int instanceIndex) {
    data[instanceIndex]!.selectedPost = math.min(
      data[instanceIndex]!.selectedPost + 1,
      (data[instanceIndex]!.content?.length?? 0) - 1,
    );
    contextInstance.doUpdate(instanceIndex);
  }

  bool hasPrevPost(int instanceIndex) {
    return data[instanceIndex]!.selectedPost > 0;
  }

  bool hasNextPost(int instanceIndex) {
    return (data[instanceIndex]!.selectedPost + 1) <
        (data[instanceIndex]!.content?.length?? 0);
  }


  void onChangePostCarousel(int instanceIndex, int value) {
    data[instanceIndex]!.selectedPostCarousel = value;
    contextInstance.doUpdate(instanceIndex);
  }

  void goPrevCarouselImage(int instanceIndex, int postIndex) {
    data[instanceIndex]!.simplePageController.previousPage(duration: Duration(milliseconds: 600), curve: Curves.ease);

    data[instanceIndex]!.selectedPostCarousel = math.max(
      data[instanceIndex]!.selectedPostCarousel - 1, 0,
    );

    contextInstance.doUpdate(instanceIndex);
  }

  void goNextCarouselImage(int instanceIndex, int postIndex) {
    data[instanceIndex]!.simplePageController.nextPage(duration: Duration(milliseconds: 600), curve: Curves.ease);

    data[instanceIndex]!.selectedPostCarousel = math.min(
      data[instanceIndex]!.selectedPostCarousel + 1,
      data[instanceIndex]!.providers[postIndex].length - 1,
    );

    contextInstance.doUpdate(instanceIndex);
  }

  bool hasPrevImage(int instanceIndex) {
    return data[instanceIndex]!.selectedPostCarousel > 0;
  }

  bool hasNextImage(int instanceIndex, int postIndex) {
    return (data[instanceIndex]!.selectedPostCarousel + 1) <
        data[instanceIndex]!.providers[postIndex].length;
  }

  void resetCarousel(int instanceIndex, [bool jumpToPage = false]) {
    if (jumpToPage) {
      data[instanceIndex]!.simplePageController.jumpToPage(
        data[instanceIndex]!.simplePageController.initialPage,
      );
    }
    data[instanceIndex]!.selectedPostCarousel = 0;
  }
}
