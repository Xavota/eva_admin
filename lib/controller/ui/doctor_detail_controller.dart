import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/helpers/utils/my_utils.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';
import 'package:blix_essentials/blix_essentials.dart';

class DoctorDetailController extends MyController{
  final manager = DBManager.instance!;

  DoctorModel? selectedDoctor;

  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));

  Future<void> updateDoctorInfo(int index) async {
    final docs = await manager.doctors;
    if (docs == null) return;
    selectedDoctor = docs[index];
  }
}