import 'package:get/get.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/prescription_model.dart';
import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/db_manager.dart';


class PatientPrescriptionDetailController extends MyController {
  final manager = DBManager.instance!;

  PatientListModel? loggedPatient;
  PrescriptionModel? selectedPrescription;
  int _prescriptionIndex = -1;


  Future<void> updateInfo(int prescriptionIndex) async {
    loggedPatient = AuthService.loggedUserData as PatientListModel;

    _prescriptionIndex = prescriptionIndex;
    final prescriptions = await manager.prescription[loggedPatient!.owner.userNumber][loggedPatient!.userNumber];
    if (prescriptions == null) return;
    selectedPrescription = prescriptions[_prescriptionIndex];
  }
}
