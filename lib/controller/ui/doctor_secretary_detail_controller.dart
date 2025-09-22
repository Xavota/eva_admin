import 'dart:typed_data';

//import 'package:printing/printing.dart';
import 'package:get/get.dart';

import 'package:medicare/helpers/utils/my_utils.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/model/secretary_model.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';

//import 'package:blix_essentials/blix_essentials.dart';

class DoctorSecretaryDetailController extends MyController {
  final manager = DBManager.instance!;

  SecretaryModel? selectedSecretary;

  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));


  Future<void> updateSecretaryInfo() async {
    selectedSecretary = await manager.secretaries[AuthService.loggedUserNumber];
  }

  void goEditScreen() {
    Get.toNamed('/doctor/secretary/edit');
  }
}