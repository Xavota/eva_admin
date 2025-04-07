import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:get/get.dart';

class DoctorListController extends MyController {
  List<DoctorModel> doctors = [];

  @override
  void onInit() {
    DoctorModel.dummyList.then((value) {
      doctors = value;
      update();
    });
    super.onInit();
  }

  void goEditDoctorScreen() {
    Get.toNamed('/admin/doctor/edit');
  }

  void goDetailDoctorScreen() {
    Get.toNamed('/admin/doctor/detail');
  }

  void addDoctor() {
    Get.toNamed('/admin/doctor/add');
  }
}
