import 'package:medicare/model/doctor_model.dart';
import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_validators.dart';
//import 'package:medicare/helpers/widgets/my_text_utils.dart';
import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
//import 'package:get/get.dart';

import 'package:medicare/db_manager.dart';
//import 'package:blix_essentials/blix_essentials.dart';

enum Gender {
  male,
  female;

  const Gender();
}

enum Department {
  kOrthopedic,
  kRadiology,
  kDentist,
  kNeurology;

  const Department();
}

class DoctorEditController extends MyController {
  final manager = DBManager.instance!;

  //Gender gender = Gender.male;
  //DateTime? selectedDate;
  MyFormValidator basicValidator = MyFormValidator();
  //List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));
  //late TextEditingController firstNameTE, lastNameTE, userNameTE, educationTE, cityTE, stateTE, addressTE, mobileNumberTE, emailAddressTE, designationTE, countryTE, postalCodeTE, biographyTE;
  DoctorModel? selectedDoctor;

  bool loading = false;

  @override
  void onInit() {

    /*firstNameTE = TextEditingController(text: "Steven");
    lastNameTE = TextEditingController(text: "Vance");
    userNameTE = TextEditingController(text: "steven_359");
    educationTE = TextEditingController(text: "M.B.B.S, M.S.");
    cityTE = TextEditingController(text: "California");
    stateTE = TextEditingController(text: "California");
    addressTE = TextEditingController(text: "2827 Jacobi Lake, Lake Jonathontown, SD 14263");
    mobileNumberTE = TextEditingController(text: "+1 23 456890");
    emailAddressTE = TextEditingController(text: "steven@example.com");
    designationTE = TextEditingController(text: "Physician");
    countryTE = TextEditingController(text: "USA");
    postalCodeTE = TextEditingController(text: "8474");
    biographyTE = TextEditingController(text: dummyTexts[0]);*/

    basicValidator.addField(
      'userNumber', required: true, label: "Número de usuario",
      controller: TextEditingController(),
    );

    /// TODO: ESTO, EN VEZ DE MOSTRAR EL NIP EN UN FIELD PARA CAMBIARLO, YA QUE
    ///       EL NIP NO SE GUARDA CRUDO SINO ENCRIPTADO Y POR LO TANTO NO SE
    ///       PUEDE RECUPERAR ASÍ COMO ASÍ, ENTONCES TIENE QUE SER EN OTRO LADO
    ///       EL CAMBIO DE NIP, DE UNA FORMA MÁS SEGURA.
    basicValidator.addField(
      'pin', label: "NIP",
      validators: [MyIntegerValidator(exactLength: 4)],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'professionalNumber', required: true, label: "Cédula Profesional",
      validators: [MyProNumberValidator()],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'fullName', required: true, label: "Nombre Completo",
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'speciality', required: true, label: "Especialidad",
      controller: TextEditingController(),
    );

    /// TODO: ESTO NO ES UN FIELD, SINO UN CHECKBOX, HAY QUE VER CÒMO HACER ESO
    /*basicValidator.addField(
      'status', required: true, label: "Estatus",
      controller: TextEditingController(),
    );*/

    super.onInit();
  }

  Future<void> updateDoctorInfo(int index) async {
    final docs = await manager.doctors;
    if (docs == null) return;
    selectedDoctor = docs[index];

    basicValidator.getController("userNumber")!.text = MyStringUtils.addZerosAtFront(selectedDoctor!.userNumber, lengthRequired: 4);
    basicValidator.getController("professionalNumber")!.text = selectedDoctor!.professionalNumber.toString();
    basicValidator.getController("fullName")!.text = selectedDoctor!.fullName.toString();
    basicValidator.getController("speciality")!.text = selectedDoctor!.speciality.toString();

    update();
  }

  Future<String?> onUpdate() async {
    String? validationError;

    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await DBManager.instance!.updateDoctor(basicValidator.getData());
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
    }

    return validationError;
  }

  /*void onChangeGender(Gender? value) {
    gender = value ?? gender;
    update();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }*/
}
