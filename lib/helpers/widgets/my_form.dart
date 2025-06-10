import 'package:flutter/material.dart';

import 'package:blix_essentials/blix_essentials.dart';

//Map<String, List<GlobalKey>> _formKeys = {};
//Map<String, int> _formIndices = {};

class MyForm extends StatefulWidget {
  const MyForm({
    super.key, required this.addNewFormKey,
    required this.disposeFormKey,
    required this.child});

  final GlobalKey<FormState> Function() addNewFormKey;
  final void Function(GlobalKey<FormState>) disposeFormKey;
  final Widget child;

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  GlobalKey<FormState>? formKey;

  @override
  void initState() {
    super.initState();
    formKey = widget.addNewFormKey();

    Debug.log("Form initState. Key: $formKey", overrideColor: Colors.yellowAccent);
  }

  @override
  void dispose() {
    Debug.log("Form dispose. Key: $formKey", overrideColor: Colors.yellowAccent);

    widget.disposeFormKey(formKey!);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Debug.log("MyForm build. formKey = $formKey", overrideColor: Colors.teal);
    return Form(
      key: formKey,
      child: widget.child,
    );
  }
}