import 'package:medicare/helpers/utils/my_string_utils.dart';
import 'package:medicare/helpers/widgets/my_field_validator.dart';

class MyEmailValidator extends MyFieldValidatorRule<String> {
  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (!required) {
      if (value == null) {
        return null;
      }
    } else if (value != null && value.isNotEmpty) {
      if (!MyStringUtils.isEmail(value)) {
        return "Please enter valid email";
      }
    }
    return null;
  }
}

class MyLengthValidator implements MyFieldValidatorRule<String> {
  final bool short, required;
  final int? min, max, exact;

  MyLengthValidator({this.required = true, this.exact, this.min, this.max, this.short = false});

  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (value != null) {
      if (!required && value.isEmpty) {
        return null;
      }
      if (exact != null && value.length != exact!) {
        //return short ? "Need $exact characters" : "Need exact $exact characters";
        return short ? "Necesita $exact caracteres" : "Necesita extactamente $exact caracteres";
      }
      if (min != null && value.length < min!) {
        return short ? "Mínimo $exact caracteres" : "Necesita al menos $min caracteres";
      }
      if (max != null && value.length > max!) {
        return short ? "Máximo $max caracteres" : "Tiene que ser menor a $max caracteres";
      }
    }
    return null;
  }
}
