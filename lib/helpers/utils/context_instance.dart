import 'dart:math' as math;
import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';


class _InstanceKeyInfo {
  _InstanceKeyInfo(this.globalKey, [this.contentSize, this.shouldCalculateSize = true]);

  GlobalKey globalKey;
  Size? contentSize;
  bool shouldCalculateSize;
}

class _InstanceInfo {
  _InstanceInfo(this.instanceKeys, this.formKeys, this.canUpdate) : pendingUpdateActions = [];
  _InstanceInfo.empty() : instanceKeys = {}, formKeys = {}, canUpdate = false, pendingUpdateActions = [];

  Map<String, _InstanceKeyInfo> instanceKeys;
  Map<String, GlobalKey<FormState>> formKeys;
  bool canUpdate;

  List<String> pendingUpdateActions;
}

class ContextInstance {
  ContextInstance(this.update, {this.onInstanceAdded, this.onInstanceRemoved});

  final void Function() update;
  final void Function(int)? onInstanceAdded;
  final void Function(int)? onInstanceRemoved;

  int updateInstanceIndex = -1;
  final Map<int, _InstanceInfo> _instancesInfo = {};
  GlobalKey? getContentKey(int instanceIndex, String name) {
    return _instancesInfo[instanceIndex]!.instanceKeys[name]?.globalKey;
  }
  GlobalKey<FormState>? getFormKey(int instanceIndex, String name) {
    return _instancesInfo[instanceIndex]!.formKeys[name];
  }
  GlobalKey<FormState>? getPrevFormKey(int instanceIndex, String name) {
    if (_instancesInfo.entries.length <= 1) return null;
    int lastIndex = _instancesInfo.keys.fold<int>(-1, (i, e) {
      if (e < instanceIndex) {
        i = math.max(i, e);
      }
      return i;
    });
    if (lastIndex == -1) return null;
    return _instancesInfo[lastIndex]!.formKeys[name];
  }
  Size? getContentSize(int instanceIndex, String keyName) {
    return _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize;
  }
  double? getContentWidth(int instanceIndex, String keyName) {
    return _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize?.width;
  }
  double? getContentHeight(int instanceIndex, String keyName) {
    return _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize?.height;
  }
  int getInstancesCount() {
    return _instancesInfo.length;
  }
  void printInstanceKeys() {
    String printText = "";
    for (final instance in _instancesInfo.entries) {
      printText += "Instance: ${instance.key}, Keys: {";
      for (final k in instance.value.instanceKeys.entries) {
        printText += "${k.key}: ${k.value.globalKey}, ";
      }
      printText += "}";
    }
    Debug.log(printText);
  }

  int addInstance() {
    int newIndex = -1;
    for (final i in _instancesInfo.keys) {
      newIndex = math.max(i, newIndex);
    }
    ++newIndex;
    _instancesInfo[newIndex] = _InstanceInfo.empty();
    onInstanceAdded?.call(newIndex);

    return newIndex;
  }

  void disposeInstance(int index) {
    onInstanceRemoved?.call(index);
    _instancesInfo.remove(index);
  }


  void addInstanceKey(int index, String name) {
    _instancesInfo[index]!.instanceKeys[name] = _InstanceKeyInfo(GlobalKey());
  }
  void addFormKey(int index, String name) {
    _instancesInfo[index]!.formKeys[name] = GlobalKey<FormState>();
  }

  void removeInstanceKey(int index, String name) {
    _instancesInfo[index]!.instanceKeys.remove(name);
  }
  void removeFormKey(int index, String name) {
    _instancesInfo[index]!.formKeys.remove(name);
  }

  void doUpdate(int instanceIndex, [bool preventDuplicates = false]) {
    if (preventDuplicates) {
      if (!_instancesInfo[instanceIndex]!.canUpdate) {
        _instancesInfo[instanceIndex]!.canUpdate = true;
        return;
      }
      //Debug.log("doUpdate, preventDuplicates == true", overrideColor: Colors.lightBlueAccent);
      _instancesInfo[instanceIndex]!.canUpdate = false;
      updateInstanceIndex = instanceIndex;
      update();
      return;
    }
    //Debug.log("doUpdate, preventDuplicates == false", overrideColor: Colors.lightBlueAccent);
    updateInstanceIndex = instanceIndex;
    update();
  }

  void calculateContentSize(int instanceIndex, String keyName,
      {bool preventDuplicates = false, bool makeUpdate = true}) {
    if (!(_instancesInfo[instanceIndex]!.instanceKeys[keyName]?.shouldCalculateSize?? true)) {
      _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.shouldCalculateSize = true;
      //Debug.log("Skipped Content Width Calc: $instanceIndex", overrideColor: Colors.white);
      return;
    }

    _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize = null;

    final RenderBox? box = getContentKey(instanceIndex, keyName)!.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize = Size(box.size.width, box.size.height);

    _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.shouldCalculateSize = false;

    //Debug.log("Calculated Content Width: $instanceIndex", overrideColor: Colors.white);
    if (makeUpdate) doUpdate(instanceIndex, preventDuplicates);
  }
}