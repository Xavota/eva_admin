import 'package:flutter/material.dart';

import 'package:get/get.dart';


import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';

import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/views/my_controller.dart';

import 'package:medicare/model/patient_list_model.dart';


import 'package:blix_essentials/blix_essentials.dart';


class DoctorPatientEditController extends MyController {
  final manager = DBManager.instance!;
  List<GlobalKey<FormState>> formKeys = [];

  bool loading = false;


  MyFormValidator basicValidator = MyFormValidator();
  PatientListModel? selectedPatient;


  Sex sex = Sex.male;
  DateTime? selectedDate;
  List<ConsultationReason> consultationReasons = [];


  @override
  void onInit() {
    basicValidator.addField(
      'userNumber', required: true, label: "Número de usuario",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'pin', label: "NIP",
      validators: [MyIntegerValidator(exactLength: 4)],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'fullName', required: true, label: "Nombre completo",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'age', required: true, label: "Edad",
      controller: TextEditingController(),
      validators: [MyIntegerValidator(maxLength: 3)],
    );

    basicValidator.addField(
      'weight', required: true, label: "Peso",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'height', required: true, label: "Altura",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'waist', required: true, label: "Cintura",
      controller: TextEditingController(),
      validators: [MyFloatingPointValidator(maxLengthBeforePoint: 3, maxLengthAfterPoint: 2)],
    );

    basicValidator.addField(
      'job', required: true, label: "Ocupación",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'birthDate', required: true, label: "Fecha de nacimiento",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'phoneNumber', required: true, label: "Número de teléfono",
      controller: TextEditingController(),
      validators: [MyIntegerValidator(exactLength: 10)],
    );

    super.onInit();
  }

  Future<void> updatePatientInfo(int index) async {
    final patients = await manager.patients[AuthService.loggedUserNumber];
    if (patients == null) return;
    selectedPatient = patients[index];

    basicValidator.getController("userNumber")!.text = selectedPatient!.userNumber;
    basicValidator.getController("fullName")!.text = selectedPatient!.fullName;
    basicValidator.getController("age")!.text = selectedPatient!.age.toString();
    sex = selectedPatient!.sex;
    basicValidator.getController("weight")!.text = selectedPatient!.weight.toString();
    basicValidator.getController("height")!.text = selectedPatient!.height.toString();
    basicValidator.getController("waist")!.text = selectedPatient!.waist.toString();
    basicValidator.getController("job")!.text = selectedPatient!.job;
    basicValidator.getController("birthDate")!.text = dateFormatter.format(selectedPatient!.birthDate);
    selectedDate = selectedPatient!.birthDate;
    basicValidator.getController("phoneNumber")!.text = selectedPatient!.phoneNumber;
    consultationReasons = selectedPatient!.consultationReasons;
    basicValidator.onChanged<List<ConsultationReason>>('consultation')(consultationReasons);

    update();
  }


  void clearPin() {
    basicValidator.getController('pin')!.text = "";
  }


  GlobalKey<FormState> addNewFormKey() {
    formKeys.add(GlobalKey());
    basicValidator.formKey = formKeys.last;
    return basicValidator.formKey;
  }

  void disposeFormKey(GlobalKey<FormState> key) {
    if (formKeys.contains(key)) {
      formKeys.remove(key);
    }
    basicValidator.formKey = formKeys.last;
  }


  void onChangeSex(Sex? value) {
    sex = value ?? sex;
    basicValidator.onChanged<Sex>('sex')(sex);
    update();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!, initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900, 1), lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      //basicValidator.onChanged<DateTime>('birthDate')(picked);
      basicValidator.getController('birthDate')!.text = selectedDate != null ? dateFormatter.format(selectedDate!) : "";
      update();
    }
  }

  void onConsultationChange(List<ConsultationReason> reasons) {
    consultationReasons = reasons;
    basicValidator.onChanged<List<ConsultationReason>>('consultation')(consultationReasons);
    update();
  }

  void removeConsultation(ConsultationReason reason) {
    consultationReasons.remove(reason);
    basicValidator.onChanged<List<ConsultationReason>>('consultation')(consultationReasons);
    Debug.log("Current consultation reasons: [${consultationReasons.map<String>((e) => e.name).toList().join(", ")}]", overrideColor: Colors.redAccent);
    update();
  }

  Future<String?> onUpdate() async {
    String? validationError;

    final data = basicValidator.getData();
    Debug.log(data, overrideColor: Colors.purple);

    if (!data.containsKey('consultation') || data['consultation'] == null || data['consultation'].isEmpty) {
      if (!basicValidator.errors.containsKey('consultation')) {
        basicValidator.addErrors({'consultation' : "Este campo es obligatorio"});
      }
      Debug.log("consultation not found", overrideColor: Colors.purpleAccent);
      validationError = "Hay errores en algunos datos";
    }
    else {
      basicValidator.errors.remove('consultation');
    }

    if (basicValidator.validateForm()) {
      // Validate non-textField data
      if (!data.containsKey('sex')) {
        data['sex'] = Sex.male;
      }

      if (validationError != null) {
        update();
        return validationError;
      }

      loading = true;
      update();
      data['birthDate'] = selectedDate.toString();
      var errors = await DBManager.instance!.updatePatient(data);
      if (errors != null) {
        if (errors.containsKey("server")) {
          validationError = errors["server"];
          errors.remove("server");
        }
        if (errors.isNotEmpty) {
          basicValidator.addErrors(errors);
          basicValidator.validateForm();
          basicValidator.clearErrors();
          validationError = "Hay errores en algunos datos";
        }
      }
      loading = false;
      update();
    }
    else {
      validationError = "Hay errores en algunos datos";
      update();
    }

    return validationError;
  }
}