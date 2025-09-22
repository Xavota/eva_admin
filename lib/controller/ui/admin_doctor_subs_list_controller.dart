import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:get/get.dart';

import 'package:medicare/db_manager.dart';

class _DoctorFilters {
  _DoctorFilters();

  String? name;
  bool? status;

  bool patientPassFilter(DoctorModel doctor) {
    if (name != null && name!.isNotEmpty && !doctor.fullName.contains(name!)) return false;
    if (status != null && doctor.status != status) return false;

    return true;
  }
}

class AdminDoctorSubsListController extends MyController {
  final manager = DBManager.instance!;

  List<DoctorModel> _doctors = [];
  List<DoctorModel> get doctors {
    return _doctors.where((e) => _filter.patientPassFilter(e)).toList();
  }

  final _DoctorFilters _filter = _DoctorFilters();

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
    Get.toNamed('/panel/doctor/edit/$index');
    //Get.offAllNamed('/panel/doctor/edit/$index');
  }

  void goDetailDoctorScreen(int index) {
    Get.toNamed('/panel/doctor/detail/$index');
  }

  void addDoctor() {
    Get.toNamed('/panel/doctor/add');
  }

  Future<bool> changeDoctorStatus(int index, bool newStatus) async {
    if (await manager.changeDoctorStatus(_doctors[index].userNumber, newStatus)) {
      updateDoctors();
      return true;
    }
    return false;
  }

  void setStatusFilter(bool? status) {
    _filter.status = status;
    update();
  }

  bool? getStatusFilter() {
    return _filter.status;
  }

  void setNameFilter(String? name) {
    _filter.name = name;
    update();
  }

  String? getNameFilter() {
    return _filter.name;
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
