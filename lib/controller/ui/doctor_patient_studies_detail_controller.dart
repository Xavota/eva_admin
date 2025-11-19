import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/model/study_model.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';

class DoctorPatientStudiesDetailData {
  PatientListModel? selectedPatient;
  int patientIndex = -1;

  StudyModel? selectedStudy;
  int studyIndex = -1;

  int viewImageIndex = -1;

  List<(double?, ImageProvider)> providers = [];
  List<Completer<double>> providersCompleter = [];
}

class DoctorPatientStudiesDetailController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = DoctorPatientStudiesDetailData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );

  Map<int, DoctorPatientStudiesDetailData> data = {};


  Future<void> updateInfo(int instanceIndex, int patientIndex, int studyIndex) async {
    data[instanceIndex]!.patientIndex = patientIndex;
    data[instanceIndex]!.studyIndex = studyIndex;

    final patients = await manager.patients[AuthService.loggedUserNumber];
    if (patients == null) return;
    data[instanceIndex]!.selectedPatient = patients[patientIndex];

    final studies = await manager.studies[AuthService.loggedUserNumber][data[instanceIndex]!.selectedPatient!.userNumber];
    if (studies == null) return;
    data[instanceIndex]!.selectedStudy = studies[data[instanceIndex]!.studyIndex];

    final study = data[instanceIndex]!.selectedStudy!;
    data[instanceIndex]!.providersCompleter = List.generate(
      study.images.length,
          (i) => Completer()..future.then((aspect) {
        final provider = data[instanceIndex]!.providers[i].$2;
        data[instanceIndex]!.providers[i] = (aspect, provider);
      }),
    );
    data[instanceIndex]!.providers = study.images.mapIndexed<(double?, ImageProvider)>((i, e) {
      final image = CachedNetworkImageProvider(
          manager.getUploadUrl("images/studies/$e"));

      image
          .resolve(ImageConfiguration())
          .addListener(
        ImageStreamListener(
              (ImageInfo info, bool _) {
            data[instanceIndex]!.providersCompleter[i]
                .complete(info.image.width / info.image.height);
          },
        ),
      );

      return (null, image);
    }).toList();

    Future.wait(
      data[instanceIndex]!.providersCompleter
          .fold<List<Future<dynamic>>>(
        [], (i, e) => i..add(e.future),
      ),
    ).then((_) {
      contextInstance.doUpdate(instanceIndex);
    });

    contextInstance.doUpdate(instanceIndex);
  }

  void showPDFPreview(int instanceIndex) {
    final pdfName = data[instanceIndex]!.selectedStudy!.pdf;
    if (pdfName.isEmpty) return;

    final pdfURL = manager.getUploadUrl("pdf/studies/$pdfName");
    launchUrl(Uri.parse(pdfURL));
  }


  void onChangeViewedImage(int instanceIndex, int newPost) {
    data[instanceIndex]!.viewImageIndex = newPost;
    contextInstance.doUpdate(instanceIndex);
  }

  void goPrevImage(int instanceIndex) {
    data[instanceIndex]!.viewImageIndex = math.max(data[instanceIndex]!.viewImageIndex - 1,  0);
    contextInstance.doUpdate(instanceIndex);
  }

  void goNextImage(int instanceIndex) {
    data[instanceIndex]!.viewImageIndex = math.min(
      data[instanceIndex]!.viewImageIndex + 1,
      data[instanceIndex]!.providers.length - 1,
    );
    contextInstance.doUpdate(instanceIndex);
  }

  bool hasPrevImage(int instanceIndex) {
    return data[instanceIndex]!.viewImageIndex > 0;
  }

  bool hasNextImage(int instanceIndex) {
    return (data[instanceIndex]!.viewImageIndex + 1) <
        data[instanceIndex]!.providers.length;
  }
}
