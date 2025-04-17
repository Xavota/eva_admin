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
        return "Por favor, introduzca un correo válido";
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

class MyDoctorUserNumberValidator extends MyFieldValidatorRule<String> {
  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (!required && value == null) {
      return null;
    }

    if (value != null && value.isNotEmpty) {
      final userNumber = int.tryParse(value);
      if (userNumber == null || userNumber <= 0 || userNumber > 1000) {
        return "Debería ser entre 1 y 1000 para doctores.";
      }
    }
    return null;
  }
}

class MyUserNumberValidator extends MyFieldValidatorRule<String> {
  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (!required && value == null) {
      return null;
    }

    if (value != null && value.isNotEmpty) {
      final userNumber = int.tryParse(value);
      if (userNumber == null || userNumber <= 1000) {
        return "Debería ser mayor a 1000.";
      }
    }
    return null;
  }
}

class MyIntegerValidator extends MyFieldValidatorRule<String> {
  final int? min, max;
  final bool minInclusive, maxInclusive;
  final int? minLength, maxLength, exactLength;
  MyIntegerValidator({this.min, this.max,
    this.minInclusive = true, this.maxInclusive = false,
    this.minLength, this.maxLength, this.exactLength});

  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (!required && (value?? "").isEmpty) return null;

    final userNumber = int.tryParse(value!);
    if (userNumber == null) return "Debería ser un número entero válido";


    /// Check for length
    String constructedErrorMsg = "Debería tener ";
    if (exactLength != null) {
      constructedErrorMsg += "exactamente $exactLength dígitos";
    }
    if (minLength != null && maxLength == null) {
      constructedErrorMsg += "más de $minLength dígitos";
    }
    else if (minLength == null && maxLength != null) {
      constructedErrorMsg += "menos de $maxLength dígitos";
    }
    else if (minLength != null && maxLength != null) {
      constructedErrorMsg += "entre $minLength y $maxLength dígitos";
    }

    if (exactLength != null && value.length != exactLength!) {
      return constructedErrorMsg;
    }
    if (minLength != null && value.length < minLength!) {
      return constructedErrorMsg;
    }
    if (maxLength != null && value.length > maxLength!) {
      return constructedErrorMsg;
    }


    /// Check for range
    constructedErrorMsg = "Debería ";
    if (min != null && max == null) {
      constructedErrorMsg += "ser mayor a ${(minInclusive ? "[" : "(")}$min${(minInclusive ? "]" : ")")}";
    }
    else if (min == null && max != null) {
      constructedErrorMsg += "ser menor a ${(maxInclusive ? "[" : "(")}$max${(maxInclusive ? "]" : ")")}";
    }
    else if (min != null && max != null) {
      constructedErrorMsg += "estar en el rango ${(minInclusive ? "[" : "(")}$min, $max${(maxInclusive ? "]" : ")")}";
    }

    if (min != null && (minInclusive ? userNumber < min! : userNumber <= min!)) {
      return constructedErrorMsg;
    }
    if (max != null && (maxInclusive ? userNumber > max! : userNumber >= max!)) {
      return constructedErrorMsg;
    }

    return null;
  }
}

class MyPinValidator extends MyFieldValidatorRule<String> {
  final int length;

  MyPinValidator({this.length = 4});

  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (!required && (value?? "").isEmpty) return null;

    if (value!.length != length) {
      return "Debe tener exactamente $length dígitos";
    }
    final pin = int.tryParse(value);
    if (pin == null) {
      return "Debe ser un número entero válido.";
    }
    return null;
  }
}

class MyProNumberValidator extends MyFieldValidatorRule<String> {
  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (!required) {
      if (value == null) {
        return null;
      }
    } else if (value != null && value.isNotEmpty) {
      if (value.length != 8) {
        return "Cédula profesional inválida";
      }
    }
    return null;
  }
}