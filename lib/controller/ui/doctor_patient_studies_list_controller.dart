import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/study_model.dart';
import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientStudiesListInstanceData {
  PatientListModel? selectedPatient;
  int patientIndex = -1;

  List<StudyModel> studies = [];
}

class DoctorPatientStudiesListController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = DoctorPatientStudiesListInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );

  Map<int, DoctorPatientStudiesListInstanceData> data = {};



  Future<void> updatePatientInfo(int instanceIndex, int index) async {
    data[instanceIndex]!.patientIndex = index;
    final patient = await manager.patients[AuthService.loggedUserNumber];
    if (patient == null) return;
    data[instanceIndex]!.selectedPatient = patient[data[instanceIndex]!.patientIndex];
  }

  void updateStudies(int instanceIndex, bool preventDuplicate) {
    if (data[instanceIndex]!.selectedPatient == null) return;

    manager.getPatientStudies(data[instanceIndex]!.selectedPatient!.userNumber, AuthService.loggedUserNumber).then((studiesInfo) {
      if (studiesInfo == null) {
        StudyModel.dummyList.then((value) {
          data[instanceIndex]!.studies = value;
          contextInstance.doUpdate(instanceIndex, preventDuplicate);
        });
        return;
      }

      data[instanceIndex]!.studies = studiesInfo;
      contextInstance.doUpdate(instanceIndex, preventDuplicate);
    });
  }


  void goDetailScreen(int instanceIndex, int index) {
    Get.toNamed('/doctor/patient/${data[instanceIndex]!.patientIndex}/studies/$index/detail');
  }

  void goAddScreen(int instanceIndex) {
    Get.toNamed('/doctor/patient/${data[instanceIndex]!.patientIndex}/studies/add');
  }


  void askToDeleteStudy({required BuildContext context, double width = 400,
    double? height, Widget? title, Widget? child, Widget? buttons}) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          child: SizedBox(
            width: 400,
            height: height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) title,
                Divider(height: 0, thickness: 1),
                if (child != null) child,
                Divider(height: 0, thickness: 1),
                if (buttons != null) buttons,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> confirmDeleteStudy(int instanceIndex, int index) async {
    await manager.deleteStudy(data[instanceIndex]!.studies[index].id);
  }
}
