import 'package:medicare/helpers/widgets/my_form_validator.dart';
import 'package:medicare/helpers/widgets/my_text_utils.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Gender {
  male,
  female;

  const Gender();
}

enum Department {
  Orthopedic,
  Radiology,
  Dentist,
  Neurology;

  const Department();
}

class DoctorEditController extends MyController {
  Gender gender = Gender.male;
  DateTime? selectedDate;
  MyFormValidator basicValidator = MyFormValidator();
  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));
  late TextEditingController firstNameTE, lastNameTE, userNameTE, educationTE, cityTE, stateTE, addressTE, mobileNumberTE, emailAddressTE, designationTE, countryTE, postalCodeTE, biographyTE;

  @override
  void onInit() {
    firstNameTE = TextEditingController(text: "Steven");
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
    biographyTE = TextEditingController(text: dummyTexts[0]);
    super.onInit();
  }

  void onChangeGender(Gender? value) {
    gender = value ?? gender;
    update();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }
}
