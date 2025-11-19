import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';

import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/helpers/utils/context_instance.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';

import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/db_manager.dart';


class UploadFileInfo {
  const UploadFileInfo(this.name, this.data, this.mime);

  final String name;
  final Uint8List data;
  final String mime;
}

class PostImage {
  const PostImage(this.provider, this.uploadInfo);

  final ImageProvider provider;
  final UploadFileInfo? uploadInfo;
}


class DoctorPatientStudiesAddInstanceData {
  PatientListModel? selectedPatient;
  int patientIndex = -1;

  final TextEditingController dropZoneTControllerImage = TextEditingController();
  final TextEditingController dropZoneTControllerPdf = TextEditingController();

  bool withImages = false;

  UploadFileInfo? pdfFile;
  final List<PostImage> images = [];
  List<ImageProvider> get imageProviders {
    return images.map((e) => e.provider).toList();
  }
}

class DoctorPatientStudiesAddController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  late final ContextInstance contextInstance = ContextInstance(
    update,
    onInstanceAdded: (index) {
      data[index] = DoctorPatientStudiesAddInstanceData();
      contextInstance.addInstanceKey(index, "global");
      contextInstance.addInstanceKey(index, "content");
    },
    onInstanceRemoved: (index) {
      if (data.containsKey(index)) data.remove(index);
      contextInstance.removeInstanceKey(index, "global");
      contextInstance.removeInstanceKey(index, "content");
    },
  );

  Map<int, DoctorPatientStudiesAddInstanceData> data = {};


  Future<void> updatePatientInfo(int instanceIndex, int index) async {
    data[instanceIndex]!.patientIndex = index;
    final patient = await manager.patients[AuthService.loggedUserNumber];
    if (patient == null) return;
    data[instanceIndex]!.selectedPatient = patient[data[instanceIndex]!.patientIndex];
  }

  @override
  void onInit() {
    super.onInit();

    basicValidator.addField(
      'description', required: true, label: "Este campo",
      controller: TextEditingController(),
    );
  }


  void clearForm(int instanceIndex) {
    basicValidator.getController('description')!.text = "";

    data[instanceIndex]!.pdfFile = null;
    data[instanceIndex]!.images.clear();

    data[instanceIndex]!.dropZoneTControllerImage.text = "";
    data[instanceIndex]!.dropZoneTControllerPdf.text = "";

    contextInstance.doUpdate(instanceIndex);
  }


  GlobalKey<FormState> addNewFormKey() {
    formKeys.add(GlobalKey());
    basicValidator.formKey = formKeys.last;
    return basicValidator.formKey;
  }

  void /**/disposeFormKey(GlobalKey<FormState> key) {
    if (formKeys.contains(key)) {
      formKeys.remove(key);
    }
    basicValidator.formKey = formKeys.isNotEmpty ? formKeys.last : GlobalKey();
  }


  void onChangeWithImage(int instanceIndex, bool newValue) {
    data[instanceIndex]!.withImages = newValue;
    contextInstance.doUpdate(instanceIndex);
  }


  void loadImage(int instanceIndex, String name, Uint8List imgData, String mime) {
    data[instanceIndex]!.images.add(PostImage(MemoryImage(imgData), UploadFileInfo(name, imgData, mime)));
    contextInstance.doUpdate(instanceIndex);
  }

  void deleteImage(int instanceIndex, int index) {
    if (index >= data[instanceIndex]!.images.length) return;
    data[instanceIndex]!.images.removeAt(index);
    contextInstance.doUpdate(instanceIndex);
  }


  void loadPDF(int instanceIndex, String name, Uint8List pdfData, String mime) {
    data[instanceIndex]!.pdfFile = UploadFileInfo(name, pdfData, mime);
    contextInstance.doUpdate(instanceIndex);
  }


  void goToList(int instanceIndex) {
    Get.toNamed('/doctor/patient/${data[instanceIndex]!.patientIndex}/studies/list');
  }


  Future<String?> onRegister(int instanceIndex) async {
    final instanceData = data[instanceIndex]!;

    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      contextInstance.doUpdate(instanceIndex);

      String pdfName = "";
      List<String> imageNames = [];
      if (!instanceData.withImages && instanceData.pdfFile != null) {
        final pdfUpload = await manager.uploadFile(
          instanceData.pdfFile!.name, instanceData.pdfFile!.data,
          MediaType.parse(instanceData.pdfFile!.mime), "pdf/studies/",
        );
        if (!pdfUpload.success) {
          loading = false;
          contextInstance.doUpdate(instanceIndex);
          return "El pdf del estudio no se subió correctamente";
        }
        pdfName = pdfUpload.name.replaceAll('"', '');
      }
      else if (instanceData.withImages && instanceData.images.isNotEmpty) {
        for (final img in instanceData.images) {
          final imgUpload = await manager.uploadFile(
            img.uploadInfo!.name, img.uploadInfo!.data,
            MediaType.parse(img.uploadInfo!.mime), "images/studies/",
          );
          if (!imgUpload.success) {
            loading = false;
            contextInstance.doUpdate(instanceIndex);
            return "Una imagen del estudio no se subió correctamente";
          }
          imageNames.add(imgUpload.name.replaceAll('"', ''));
        }
      }
      else {
        loading = false;
        contextInstance.doUpdate(instanceIndex);
        return "No se puede subir un estudio sin un pdf o imágenes";
      }

      var registerInfo = await DBManager.instance!.registerStudy(
        basicValidator.getData(),
        instanceData.selectedPatient!.userNumber,
        pdfName, false,
      );
      if (registerInfo.errors != null) {
        if (registerInfo.errors!.containsKey("server")) {
          validationError = registerInfo.errors!["server"];
          registerInfo.errors!.remove("server");
        }
        if (registerInfo.errors!.isNotEmpty) {
          basicValidator.addErrors(registerInfo.errors!);
          basicValidator.validateForm();
          basicValidator.clearErrors();
          validationError = "Hay errores en algunos datos";
        }

        if (pdfName.isNotEmpty) {
          await manager.deleteFile(pdfName, "pdf/studies/");
        }
        for (final imgName in imageNames) {
          await manager.deleteFile(imgName, "images/studies/");
        }
      }
      else if (instanceData.withImages) {
        for (final imgName in imageNames) {
          await manager.registerStudyImage(imgName, registerInfo.id!);
        }
      }

      loading = false;
      contextInstance.doUpdate(instanceIndex);
    }
    else {
      validationError = "Hay errores en algunos datos";
    }

    return validationError;
  }
}
