import 'dart:math' as math;
import 'dart:async';

import 'package:blix_essentials/blix_essentials.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/premium_video_model.dart';

import 'package:medicare/db_manager.dart';

class PatientPremiumVideosListInstanceData {
  List<PremiumVideoModel>? videos;
  List<(double?, ImageProvider)> providers = [];
  List<Completer<double>> providersCompleter = [];
  String currentHeader = "";
  String currentSubHeader = "";

  int selectedVideo = -1;

  bool patientIsPremium = false;
}

class PatientPremiumVideosListController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = PatientPremiumVideosListInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );


  Map<int, PatientPremiumVideosListInstanceData> data = {};
  bool headerNotExist = false;


  Future<void> updateInfo(int instanceIndex, [String? header, String? subHeader]) async {
    data[instanceIndex]!.currentHeader = header?? data[instanceIndex]!.currentHeader;
    data[instanceIndex]!.currentSubHeader = subHeader?? data[instanceIndex]!.currentSubHeader;
    data[instanceIndex]!.videos =
        (await manager.premiumContent[PremiumContentTypes.kVideos]
        [data[instanceIndex]!.currentHeader]
        [data[instanceIndex]!.currentSubHeader])
            ?.map<PremiumVideoModel>((e) => e as PremiumVideoModel).toList();
    Debug.log("videos[instanceIndex]: ${data[instanceIndex]!.videos}", overrideColor: Colors.red);
    headerNotExist = false;
    if (data[instanceIndex]!.videos == null) {
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
    for (int b = 0; b < data[instanceIndex]!.videos!.length; ++b) {
      int videoIndex = b;
      data[instanceIndex]!.providersCompleter.add(Completer()..future.then((aspect) {
        final provider = data[instanceIndex]!.providers[videoIndex].$2;
        data[instanceIndex]!.providers[videoIndex] = (aspect, provider);
      }));


      final video = data[instanceIndex]!.videos![b];

      final image = CachedNetworkImageProvider(
          manager.getUploadUrl("images/premium_videos/${video.frontPage}"));

      image
          .resolve(ImageConfiguration())
          .addListener(
        ImageStreamListener(
              (ImageInfo info, bool _) {
            data[instanceIndex]!.providersCompleter[videoIndex]
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

    Debug.log("Videos length: ${data[instanceIndex]!.videos!.length}");
  }


  void onChangeSelectedPost(int instanceIndex, int newPost) {
    data[instanceIndex]!.selectedVideo = newPost;
    contextInstance.doUpdate(instanceIndex);
  }

  void goPrevPost(int instanceIndex) {
    data[instanceIndex]!.selectedVideo = math.max(data[instanceIndex]!.selectedVideo - 1,  0);
    contextInstance.doUpdate(instanceIndex);
  }

  void goNextPost(int instanceIndex) {
    data[instanceIndex]!.selectedVideo = math.min(
      data[instanceIndex]!.selectedVideo + 1,
      (data[instanceIndex]!.videos?.length?? 0) - 1,
    );
    contextInstance.doUpdate(instanceIndex);
  }

  bool hasPrevPost(int instanceIndex) {
    return data[instanceIndex]!.selectedVideo > 0;
  }

  bool hasNextPost(int instanceIndex) {
    return (data[instanceIndex]!.selectedVideo + 1) <
        (data[instanceIndex]!.videos?.length?? 0);
  }


  String getVideoTitle(int instanceIndex, [int? videoIndex]) {
    return data[instanceIndex]!.videos![videoIndex?? data[instanceIndex]!.selectedVideo].tile;
  }

  String getVideoEmbed(int instanceIndex, [int? videoIndex]) {
    return data[instanceIndex]!.videos![videoIndex?? data[instanceIndex]!.selectedVideo].embed;
  }


  bool coverUpVideo(int instanceIndex, int videoIndex) {
    final coverUp = !data[instanceIndex]!.videos![videoIndex].free && !data[instanceIndex]!.patientIsPremium;
    Debug.log("Video with index: $videoIndex, free: ${data[instanceIndex]!.videos![videoIndex].free ? "true" : "false"}");
    Debug.log("Video with index: $videoIndex, patientPremium: ${data[instanceIndex]!.patientIsPremium ? "true" : "false"}");
    Debug.log("Video with index: $videoIndex, coverUp: ${coverUp ? "true" : "false"}");
    return coverUp;
  }
}
