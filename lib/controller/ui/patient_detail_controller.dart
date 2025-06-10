import 'dart:typed_data';

import 'package:flutter/material.dart';

//import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
//import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import 'package:medicare/helpers/utils/my_utils.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/views/my_controller.dart';

import 'package:medicare/db_manager.dart';

import 'package:blix_essentials/blix_essentials.dart';

class PatientDetailController extends MyController {
  final manager = DBManager.instance!;

  PatientListModel? selectedPatient;
  SubscriptionStatus? subscriptionStatus;
  DateTime? subscriptionStarts;
  DateTime? subscriptionEnds;

  int patientIndex = -1;

  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));


  String? pdfFileName;
  Uint8List? pdfFileData;
  String? pdfFileMimeType;

  //Uint8List? pdfBytes;

  Future<void> updatePatientInfo(int index) async {
    patientIndex = index;
    final patient = await manager.patients[AuthService.loggedUserNumber];
    if (patient == null) return;
    selectedPatient = patient[patientIndex];

    final subInfo = await manager.getPatientSubStatus(selectedPatient!.userNumber);
    if (subInfo == null) return;
    subscriptionStatus = subInfo.$1;
    subscriptionStarts = subInfo.$2;
    subscriptionEnds = subInfo.$3;

    //_downloadPDFBytes();
  }

  /*void _downloadPDFBytes() {
    final pdfName = selectedPatient?.pdfName?? "";
    if (pdfName.isEmpty) return;

    final pdfURL = BlixDBManager.getUrl("uploads/pdf/$pdfName");

    http.get(Uri.parse(pdfURL)).then((response) {
      if (response.statusCode == 200) {
        pdfBytes = response.bodyBytes;
        update();
      }
    });
  }*/

  void goEditScreen() {
    Get.toNamed('/doctor/patient/edit/$patientIndex');
  }

  void loadPDFFile(String name, Uint8List data, String mime) {
    pdfFileName = name;
    pdfFileData = data;
    pdfFileMimeType = mime;
    Debug.log('PDF selected: $pdfFileName, ${data.length} bytes, mime: $pdfFileMimeType');
  }

  Future<String?> uploadPDFFile() async {
    if (selectedPatient == null) return "no user";

    if (pdfFileName == null || pdfFileData == null || pdfFileMimeType == null) {
      return "missing info";
    }

    if (selectedPatient!.pdfName.isNotEmpty) {
      final r = await manager.deleteFile(selectedPatient!.pdfName, "pdf/");
      if (r != null) {
        return "failed";
      }
    }

    final response = await manager.uploadFile(
      pdfFileName!, pdfFileData!, MediaType.parse(pdfFileMimeType!), "pdf/",
    );

    if (response.success) {
      if (await manager.changePatientPDFName(selectedPatient!.userNumber, response.name.replaceAll('"', ''))) {
        await manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber);
        await updatePatientInfo(patientIndex);
        Debug.log("uploadPDFFile update", overrideColor: Colors.green);
        update();
      }
      return null;
    }

    return response.name;
  }

  Future<String?> deletePDFFile() async {
    if (selectedPatient == null) return "no user";

    final response = await manager.deleteFile(selectedPatient!.pdfName, "pdf/");

    if (response == null) {
      if (await manager.changePatientPDFName(selectedPatient!.userNumber, "")) {
        await manager.getPatients(doctorOwnerID: AuthService.loggedUserNumber);
        await updatePatientInfo(patientIndex);
        update();
      }
      return null;
    }

    return response;
  }

  /*void showModalWindow(
      BuildContext context, String title, Widget body,
      String closeText, Function() onClose) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: body,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onClose();
              },
              child: Text(closeText),
            ),
          ],
        );
      },
    );
  }*/

  void showPDFPreview(BuildContext context) {
    final pdfName = selectedPatient?.pdfName?? "";
    if (pdfName.isEmpty) return;

    final pdfURL = BlixDBManager.getUrl("uploads/pdf/$pdfName");
    launchUrl(Uri.parse(pdfURL));

    /*double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showModalWindow(
      context, "Expediente",
      SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: PdfPreview(
          //canChangeOrientation: false,
          //canChangePageFormat: false,
          //canDebug: false,
          //allowPrinting: false,
          //allowSharing: false,
          build: (_) => pdfBytes!,
        ),
      ),
      "Cerrar", ()  {},
    );*/
  }
}