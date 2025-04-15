import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:get/get.dart';

import 'package:medicare/db_manager.dart';

class DoctorListController extends MyController {
  final manager = DBManager.instance!;

  List<DoctorModel> _doctors = [];
  List<DoctorModel> get doctors {
    return _doctors.where((e) => activeFilter == null || e.status == activeFilter).toList();
  }

  bool? activeFilter;

  void updateDoctors() {
    manager.getDoctors().then((ds) {
      if (ds == null) {
        DoctorModel.dummyList.then((value) {
          _doctors = value;
          update();
        });
        return;
      }

      _doctors = ds;
      update();
    });
  }

  @override
  void onInit() {
    updateDoctors();

    super.onInit();
  }

  void goEditDoctorScreen(int index) {
    Get.toNamed('/admin/doctor/edit/$index');
  }

  void goDetailDoctorScreen(int index) {
    Get.toNamed('/admin/doctor/detail/$index');
  }

  void addDoctor() {
    Get.toNamed('/admin/doctor/add');
  }

  Future<bool> changeDoctorStatus(int index, bool newStatus) async {
    if (await manager.changeDoctorStatus(_doctors[index].id, newStatus)) {
      updateDoctors();
      return true;
    }
    return false;
  }

  void setActiveFilter(bool? active) {
    activeFilter = active;
    update();
  }

  /*void toggleStatusActiveFilter() {
    if (activeFilter == null || !activeFilter!) {
      activeFilter = true;
    }
    else {
      activeFilter = null;
    }
    update();
  }
  void toggleStatusArchiveFilter() {
    if (activeFilter == null || activeFilter!) {
      activeFilter = false;
    }
    else {
      activeFilter = null;
    }
    update();
  }*/
}
