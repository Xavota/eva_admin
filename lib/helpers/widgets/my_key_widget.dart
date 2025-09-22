import 'package:flutter/material.dart';

import 'package:blix_essentials/blix_essentials.dart';

class MyKeyWidget extends StatefulWidget {
  const MyKeyWidget({
    super.key, required this.addNewKey,
    required this.disposeKey,
    required this.childFnc});

  final GlobalKey Function() addNewKey;
  final void Function(GlobalKey) disposeKey;
  final Widget Function(GlobalKey) childFnc;

  @override
  State<MyKeyWidget> createState() => _MyFormState();
}

class _MyFormState extends State<MyKeyWidget> {
  late final GlobalKey globalKey;

  @override
  void initState() {
    super.initState();
    globalKey = widget.addNewKey();

    Debug.log("MyKeyWidget initState. globalKey: $globalKey", overrideColor: Colors.yellowAccent);
  }

  @override
  void dispose() {
    Debug.log("MyKeyWidget dispose. globalKey: $globalKey", overrideColor: Colors.yellowAccent);

    widget.disposeKey(globalKey);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Debug.log("MyKeyWidget build. globalKey: $globalKey", overrideColor: Colors.teal);
    return widget.childFnc(globalKey);
  }
}