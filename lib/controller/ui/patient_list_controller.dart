import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:get/get.dart';

class PatientListController extends MyController {
  List<PatientListModel> patients =[];

  @override
  void onInit() {
    PatientListModel.dummyList.then((value) {
      patients = value;
      update();
    });
    super.onInit();
  }

  void goEditScreen() {
    Get.toNamed('/admin/patient/edit');
  }

  void goDetailScreen() {
    Get.toNamed('/admin/patient/detail');
  }

  void addPatient() {
    Get.toNamed('/admin/patient/add');
  }
}