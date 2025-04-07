import 'package:get/get.dart';
import 'package:medicare/model/appointment_list_model.dart';
import 'package:medicare/views/my_controller.dart';

class AppointmentListController extends MyController {
  List<AppointmentListModel> appointmentListModel = [];

  @override
  void onInit() {
    AppointmentListModel.dummyList.then((value) {
      appointmentListModel = value;
      update();
    });
    super.onInit();
  }

  void bookAppointment() {
    Get.toNamed('/admin/appointment_book');
  }

  void goToSchedulingEditScreen() {
    Get.toNamed('/admin/appointment_edit');
  }

  void goToSchedulingScreen() {
    Get.toNamed('/admin/appointment_scheduling');
  }
}