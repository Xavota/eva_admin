import 'package:get/get.dart';

import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/model/secretary_model.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';

class _PatientFilters {
  _PatientFilters();

  String? name;
  bool? status;
  SubscriptionStatus? subscription;
  List<ConsultationReason>? reasons;

  bool patientPassFilter(PatientListModel patient, SubscriptionStatus subStatus) {
    if (name != null && name!.isNotEmpty && !patient.fullName.contains(name!)) return false;
    if (status != null && patient.status != status) return false;
    if (subscription != null && subStatus != subscription) return false;

    if (reasons == null || reasons!.isEmpty) return true;
    for (final r in reasons!) {
      if (!patient.consultationReasons.contains(r)) return false;
    }

    return true;
  }
}

class SecretaryPatientListController extends MyController {
  final manager = DBManager.instance!;

  SecretaryModel? _loggedInSecretary;

  List<PatientListModel> _patients = [];
  List<PatientListModel> get patients {
    return _patients.where((e) => _filter.patientPassFilter(e, patientSubStates[e.userNumber]?? SubscriptionStatus.kNotActive)).toList();
  }
  final Map<String, SubscriptionStatus> patientSubStates = {};

  final _PatientFilters _filter = _PatientFilters();


  void setNameFilter(String name) {
    _filter.name = name.isEmpty ? null : name;
    update();
  }

  void setStatusFilter(bool? active) {
    _filter.status = active;
    update();
  }

  bool? getStatusFilter() {
    return _filter.status;
  }

  void setSubscriptionFilter(SubscriptionStatus? active) {
    _filter.subscription = active;
    update();
  }

  SubscriptionStatus? getSubscriptionFilter() {
    return _filter.subscription;
  }

  void setConsultReasonsFilter(List<ConsultationReason>? reasons) {
    _filter.reasons = reasons;
    update();
  }

  void removeConsultReasonsFilter(ConsultationReason reason) {
    if (_filter.reasons == null) return;
    _filter.reasons!.remove(reason);
    update();
  }

  List<ConsultationReason>? getConsultReasonsFilter() {
    return _filter.reasons;
  }


  Future<void> updateSubStates() async {
    for (final p in _patients) {
      manager.getPatientSubStatus(p.userNumber).then((status) {
        if (status == null) return;
        patientSubStates[p.userNumber] = status.$1;
        update();
      });
    }
  }

  void updatePatients() {
    if (_loggedInSecretary == null) return;

    manager.getPatients(doctorOwnerID: _loggedInSecretary!.owner).then((patientsInfo) {
      if (patientsInfo == null) {
        PatientListModel.dummyList.then((value) {
          _patients = value;
          update();
          updateSubStates();
        });
        return;
      }

      _patients = patientsInfo;
      update();
      updateSubStates();
    });
  }

  @override
  void onInit() {
    _loggedInSecretary = AuthService.loggedUserData as SecretaryModel?;
    updatePatients();

    super.onInit();
  }

  /*void goEditScreen(int index) {
    Get.toNamed('/doctor/patient/edit/$index');
  }*/

  void goDetailScreen(int index) {
    Get.toNamed('/secretary/patient/detail/$index');
  }

  /*void addPatient() {
    Get.toNamed('/doctor/patient/add');
  }*/
}
