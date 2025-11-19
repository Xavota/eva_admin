import 'dart:math' as math;
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/premium_post_model.dart';
import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/db_manager.dart';

class PatientPremiumPostsListInstanceData {
  List<PremiumPostModel>? posts;
  List<List<(double?, ImageProvider)>> providers = [];
  List<List<Completer<double>>> providersCompleter = [];
  String currentHeader = "";
  String currentSubHeader = "";

  int selectedPost = 0;
  int selectedPostCarousel = 0;
  final PageController simplePageController = PageController(initialPage: 0);
}

class PatientPremiumPostsListController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = PatientPremiumPostsListInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );


  Map<int, PatientPremiumPostsListInstanceData> data = {};
  bool headerNotExist = false;

  bool patientIsPremium = false;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    //Debug.log("AAAAAAAAAAAAAAAAA INIT", overrideColor: Colors.red);
  }

  Future<void> updateInfo(int instanceIndex, [String? header, String? subHeader]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;

    if (AuthService.loggedUserData != null && AuthService.loggedUserData is PatientListModel) {
      final loggedInPatient = AuthService.loggedUserData as PatientListModel;
      final status = await manager.getPatientSubStatus(loggedInPatient.userNumber);
      patientIsPremium = status?.$1 == SubscriptionStatus.kActive;
    }

    data[instanceIndex]!.posts =
    (await manager.premiumContent[PremiumContentTypes.kPosts]
                                [data[instanceIndex]!.currentHeader]
                                [data[instanceIndex]!.currentSubHeader])
        ?.map<PremiumPostModel>((e) => e as PremiumPostModel).toList();

    if (!patientIsPremium) {
      data[instanceIndex]!.posts = data[instanceIndex]!.posts!.where((e) => e.free).toList();
    }

    headerNotExist = false;
    if (data[instanceIndex]!.posts == null) {
      headerNotExist = true;
      contextInstance.doUpdate(instanceIndex);
      return;
    }

    data[instanceIndex]!.providersCompleter = [];
    data[instanceIndex]!.providers = [];
    for (int p = 0; p < data[instanceIndex]!.posts!.length; ++p) {
      final post = data[instanceIndex]!.posts![p];
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
      contextInstance.doUpdate(instanceIndex);
    });

    contextInstance.doUpdate(instanceIndex);
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
      (data[instanceIndex]!.posts?.length?? 0) - 1,
    );
    contextInstance.doUpdate(instanceIndex);
  }

  bool hasPrevPost(int instanceIndex) {
    return data[instanceIndex]!.selectedPost > 0;
  }

  bool hasNextPost(int instanceIndex) {
    return (data[instanceIndex]!.selectedPost + 1) <
        (data[instanceIndex]!.posts?.length?? 0);
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


  bool coverUpPost(int instanceIndex, int postIndex) {
    return !data[instanceIndex]!.posts![postIndex].free && !patientIsPremium;
  }
}
