import 'dart:math' as math;
import 'package:flutter/material.dart';


class _InstanceKeyInfo {
  _InstanceKeyInfo(this.globalKey, [this.contentSize, this.shouldCalculateSize = true]);

  GlobalKey globalKey;
  Size? contentSize;
  bool shouldCalculateSize;
}

class _InstanceInfo {
  _InstanceInfo(this.instanceKeys, this.canUpdate) : pendingUpdateActions = [];
  _InstanceInfo.empty() : instanceKeys = {}, canUpdate = false, pendingUpdateActions = [];

  Map<String, _InstanceKeyInfo> instanceKeys;
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
  Size? getContentSize(int instanceIndex, String keyName) {
    return _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize;
  }
  double? getContentWidth(int instanceIndex, String keyName) {
    return _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize?.width;
  }
  double? getContentHeight(int instanceIndex, String keyName) {
    return _instancesInfo[instanceIndex]!.instanceKeys[keyName]?.contentSize?.height;
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
    _instancesInfo.remove(index);
    onInstanceRemoved?.call(index);
  }


  void addInstanceKey(int index, String name) {
    _instancesInfo[index]!.instanceKeys[name] = _InstanceKeyInfo(GlobalKey());
  }

  void removeInstanceKey(int index, String name) {
    _instancesInfo[index]!.instanceKeys.remove(name);
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