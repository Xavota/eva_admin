import 'dart:convert';

import 'package:medicare/helpers/services/json_decoder.dart';
import 'package:medicare/model/identifier_model.dart';
import 'package:flutter/services.dart';

abstract class PremiumParentModel extends IdentifierModel{
  PremiumParentModel(super.id);
}