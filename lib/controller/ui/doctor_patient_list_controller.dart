import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:get/get.dart';

import 'package:medicare/db_manager.dart';


class DoctorPatientListController extends MyController {
  final manager = DBManager.instance!;

  List<PatientListModel> _patients = [];
  List<PatientListModel> get patients {
    return _patients.where((e) => activeFilter == null || e.status == activeFilter).toList();
  }

  bool? activeFilter;

  void updatePatients() {
    manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber).then((patientsInfo) {
      if (patientsInfo == null) {
        PatientListModel.dummyList.then((value) {
          _patients = value;
          update();
        });
        return;
      }

      _patients = patientsInfo;
      update();
    });
  }

  @override
  void onInit() {
    updatePatients();

    super.onInit();
  }

  void goEditScreen(int index) {
    Get.toNamed('/doctor/patient/edit/$index');
  }

  void goDetailScreen(int index) {
    Get.toNamed('/doctor/patient/detail/$index');
  }

  void goPrescriptionScreen(int index) {
    Get.toNamed('/doctor/patient/$index/prescription/list');
  }

  void addPatient() {
    Get.toNamed('/doctor/patient/add');
  }

  Future<bool> changePatientStatus(int index, bool newStatus) async {
    if (await manager.changePatientStatus(_patients[index].userNumber, newStatus)) {
      updatePatients();
      return true;
    }
    return false;
  }

  void setActiveFilter(bool? active) {
    activeFilter = active;
    update();
  }
}
