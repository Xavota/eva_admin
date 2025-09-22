import 'package:get/get.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/prescription_model.dart';
import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/db_manager.dart';


class DoctorPatientPrescriptionDetailController extends MyController {
  final manager = DBManager.instance!;

  PatientListModel? selectedPatient;
  int _patientIndex = -1;
  PrescriptionModel? selectedPrescription;
  int _prescriptionIndex = -1;


  Future<void> updateInfo(int patientIndex, int prescriptionIndex) async {
    _patientIndex = patientIndex;
    _prescriptionIndex = prescriptionIndex;
    final patients = await manager.patients[AuthService.loggedUserNumber];
    if (patients == null) return;
    selectedPatient = patients[patientIndex];
    final prescriptions = await manager.prescription[AuthService.loggedUserNumber][selectedPatient!.userNumber];
    if (prescriptions == null) return;
    selectedPrescription = prescriptions[_prescriptionIndex];
  }

  void goEditScreen() {
    Get.toNamed('/doctor/patient/$_patientIndex/prescription/$_prescriptionIndex/edit');
  }
}
