import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/helpers/widgets/my_form_validator.dart';

import 'package:medicare/model/date_model.dart';
import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

/*class _DateFilters {
  _DateFilters();

  String? name;
  DateTime? day;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.day == b.day && a.month == b.month && a.year == b.year;
  }

  bool datePassFilter(DateModel date) {
    final fullName = date.realPatient?.fullName?? date.tempPatient?.fullName?? "";
    if (name != null && name!.isNotEmpty && !fullName.toLowerCase().contains(name!.toLowerCase())) return false;
    if (day != null && !_isSameDay(date.date, day!)) return false;

    return true;
  }
}*/

class PatientDatesListController extends MyController {
  final manager = DBManager.instance!;
  MyFormValidator basicValidator = MyFormValidator();

  PatientListModel? _loggedInPatient;

  //final _DateFilters _filter = _DateFilters();

  List<DateModel> _dates = [];
  List<DateModel> get dates {
    return _dates;//.where((e) => _filter.datePassFilter(e)).toList();
  }


  String getDoctorName(DateModel date) {
    return date.owner?.fullName?? "";
  }

  String getConsulReasons(DateModel date) {
    return (date.realPatient?.consultationReasons?? date.tempPatient?.consultationReasons?? [])
        .map<String>((e) => e.name).join(", ");
  }

  String getDateFormatted(DateTime date) {
    return "Día: ${dateFormatter.format(date)}\nHora: ${timeFormatter.format(date)}";
  }


  /*void setNameFilter(String name) {
    _filter.name = name.isEmpty ? null : name;
    update();
  }

  Future<void> pickDateFilter() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!, initialDate: _filter.day ?? DateTime.now(),
      firstDate: DateTime.now(), lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null && picked != _filter.day) {
      _filter.day = picked;
      basicValidator.getController('dateFilter')!.text = _filter.day != null ? dateFormatter.format(_filter.day!) : "";
      update();
    }
  }

  void removeDayFilter() {
    _filter.day = null;
    basicValidator.getController('dateFilter')!.text = "";
    update();
  }

  DateTime? getDayFilter() {
    return _filter.day;
  }*/


  void updateDates() {
    if (_loggedInPatient == null) return;

    manager.getDates(userNumber: _loggedInPatient!.userNumber).then((datesInfo) {
      if (datesInfo == null) {
        DateModel.dummyList.then((value) {
          _dates = value;
          update();
        });
        return;
      }

      _dates = datesInfo;
      update();
    });
  }

  @override
  void onInit() {
    basicValidator.addField(
      'dateFilter', required: true, label: "Filtro de Fecha",
      controller: TextEditingController(),
    );

    _loggedInPatient = AuthService.loggedUserData as PatientListModel?;
    updateDates();

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
