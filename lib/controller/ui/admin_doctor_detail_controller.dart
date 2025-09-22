import 'package:get/get.dart';

import 'package:medicare/helpers/utils/my_utils.dart';
import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';

class AdminDoctorDetailController extends MyController{
  final manager = DBManager.instance!;

  int medicIndex = -1;
  DoctorModel? selectedDoctor;

  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));

  Future<void> updateDoctorInfo(int index) async {
    medicIndex = index;
    final docs = await manager.doctors;
    if (docs == null) return;
    selectedDoctor = docs[medicIndex];
  }

  void goEditScreen() {
    Get.toNamed('/panel/doctor/edit/$medicIndex');
  }
}