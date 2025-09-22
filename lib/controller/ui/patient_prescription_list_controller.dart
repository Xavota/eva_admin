import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/prescription_model.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';


class _InstanceInfo {
  _InstanceInfo(this.globalKey, this.canUpdate, this.contentWidth, this.calculateWidth);

  GlobalKey globalKey;
  bool canUpdate;
  double? contentWidth;
  bool calculateWidth;
}

class PatientPrescriptionListController extends MyController {
  final manager = DBManager.instance!;

  int updateInstanceIndex = -1;
  final Map<int, _InstanceInfo> _instancesInfo = {};
  GlobalKey getContentKey(int instanceIndex) {
    return _instancesInfo[instanceIndex]!.globalKey;
  }
  double? getContentWidth(int instanceIndex) {
    return _instancesInfo[instanceIndex]!.contentWidth;
  }

  List<PrescriptionModel> _prescriptions = [];
  List<PrescriptionModel> get prescriptions {
    return _prescriptions;
  }


  void doUpdate(int instanceIndex, [bool preventDuplicates = false]) {
    if (preventDuplicates) {
      if (!_instancesInfo[instanceIndex]!.canUpdate) {
        _instancesInfo[instanceIndex]!.canUpdate = true;
        return;
      }
      Debug.log("doUpdate, preventDuplicates == true", overrideColor: Colors.lightBlueAccent);
      _instancesInfo[instanceIndex]!.canUpdate = false;
      updateInstanceIndex = instanceIndex;
      update();
      return;
    }
    Debug.log("doUpdate, preventDuplicates == false", overrideColor: Colors.lightBlueAccent);
    updateInstanceIndex = instanceIndex;
    update();
  }


  int addInstance() {
    int newIndex = -1;
    for (final i in _instancesInfo.keys) {
      newIndex = math.max(i, newIndex);
    }
    ++newIndex;
    _instancesInfo[newIndex] = _InstanceInfo(GlobalKey(), false, null, true);

    return newIndex;
  }

  void disposeInstance(int index) {
    _instancesInfo.remove(index);
  }


  void calculateContentWidth(int instanceIndex, double flexSpacing) {
    if (!_instancesInfo[instanceIndex]!.calculateWidth) {
      _instancesInfo[instanceIndex]!.calculateWidth = true;
      Debug.log("Skipped Content Width Calc: $instanceIndex", overrideColor: Colors.white);
      return;
    }

    _instancesInfo[instanceIndex]!.contentWidth = null;

    final RenderBox? box = getContentKey(instanceIndex).currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    _instancesInfo[instanceIndex]!.contentWidth = box.size.width - flexSpacing * 2.0;

    _instancesInfo[instanceIndex]!.calculateWidth = false;

    Debug.log("Calculated Content Width: $instanceIndex", overrideColor: Colors.white);
    doUpdate(instanceIndex, true);
  }

  void updatePrescriptions(int instanceIndex) {
    manager.getPatientPrescriptions(AuthService.loggedUserNumber).then((prescriptionsInfo) {
      if (prescriptionsInfo == null) {
        PrescriptionModel.dummyList.then((value) {
          _prescriptions = value;
          doUpdate(instanceIndex, true);
        });
        return;
      }

      _prescriptions = prescriptionsInfo;
      doUpdate(instanceIndex, true);
    });
  }

  void goDetailScreen(int index) {
    Get.toNamed('/patient/prescription/$index/detail');
  }
}
