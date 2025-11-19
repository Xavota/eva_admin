import 'dart:async';

import 'package:blix_essentials/blix_essentials.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/monthly_subs_model.dart';

import 'package:medicare/db_manager.dart';

enum Months {
  kJanuary,
  kFebruary,
  kMarch,
  kApril,
  kMay,
  kJune,
  kJuly,
  kAugust,
  kSeptember,
  kOctober,
  kNovember,
  kDecember,
}

extension MonthsExtension on Months {
  String get name {
    switch (this) {
      case Months.kJanuary:
        return "Enero";
      case Months.kFebruary:
        return "Febrero";
      case Months.kMarch:
        return "Marzo";
      case Months.kApril:
        return "Abril";
      case Months.kMay:
        return "Mayo";
      case Months.kJune:
        return "Junio";
      case Months.kJuly:
        return "Julio";
      case Months.kAugust:
        return "Agosto";
      case Months.kSeptember:
        return "Septiembre";
      case Months.kOctober:
        return "Octubre";
      case Months.kNovember:
        return "Noviembre";
      case Months.kDecember:
        return "Diciembre";
    }
  }
}

class AdminDoctorEarningsListInstanceData {
  Map<DateTime, List<MonthlySubsModel>> tableData = {};

  DateTime currentTime = DateTime.now();
  double price = 0.0;
}

class AdminDoctorEarningsListController extends MyController {
  final manager = DBManager.instance!;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = AdminDoctorEarningsListInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );


  Map<int, AdminDoctorEarningsListInstanceData> data = {};


  Future<void> updateInfo(int instanceIndex) async {
    data[instanceIndex]!.tableData[data[instanceIndex]!.currentTime] = (await manager.doctorsMonthlySubs[data[instanceIndex]!.currentTime])!;
    contextInstance.doUpdate(instanceIndex);
  }

  List<MonthlySubsModel> tableData(int instanceIndex) {
    return data[instanceIndex]!.tableData[data[instanceIndex]!.currentTime]?? [];
  }

  void onMonthChanged(int instanceIndex, int month) {
    final currentTime = data[instanceIndex]!.currentTime;
    data[instanceIndex]!.currentTime = DateTime(currentTime.year, month);
    updateInfo(instanceIndex);
  }

  void onYearChanged(int instanceIndex, int year) {
    final currentTime = data[instanceIndex]!.currentTime;
    data[instanceIndex]!.currentTime = DateTime(year, currentTime.month);
    updateInfo(instanceIndex);
  }

  void onPriceChanged(int instanceIndex, String priceTxt) {
    data[instanceIndex]!.price = double.tryParse(priceTxt)?? 0.0;
    contextInstance.doUpdate(instanceIndex);
  }

  Future<bool> changePayedStatus(int instanceIndex, int rowIndex, bool newStatus) async {
    final time = data[instanceIndex]!.currentTime;
    final info = data[instanceIndex]!.tableData[time]![rowIndex];
    final response = await manager.changeDoctorSubsPayedStatus(info.doctorNumber, time, newStatus);

    if (response) {
      await manager.getMonthSubs(time);
      updateInfo(instanceIndex);
    }

    return response;
  }
}
