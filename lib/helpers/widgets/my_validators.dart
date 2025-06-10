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

class MyFloatingPointValidator extends MyFieldValidatorRule<String> {
  final double? min, max;
  final bool minInclusive, maxInclusive;
  final int? minLengthBeforePoint, maxLengthBeforePoint, exactLengthBeforePoint;
  final int? minLengthAfterPoint, maxLengthAfterPoint, exactLengthAfterPoint;
  MyFloatingPointValidator({this.min, this.max,
    this.minInclusive = true, this.maxInclusive = false,
    this.minLengthBeforePoint, this.maxLengthBeforePoint, this.exactLengthBeforePoint,
    this.minLengthAfterPoint, this.maxLengthAfterPoint, this.exactLengthAfterPoint});

  @override
  String? validate(String? value, bool required, Map<String, dynamic> data) {
    if (!required && (value?? "").isEmpty) return null;

    final userNumber = double.tryParse(value!);
    if (userNumber == null) return "Debería ser un número flotante válido";

    final divided = value.split('.');
    final beforePoint = divided[0];
    final afterPoint = divided.length > 1 ? divided[1] : "";


    /// Check for length before point
    String constructedErrorMsg = "Debería tener ";
    if (exactLengthBeforePoint != null) {
      constructedErrorMsg += "exactamente $exactLengthBeforePoint dígitos antes del punto decimal";
    }
    if (minLengthBeforePoint != null && maxLengthBeforePoint == null) {
      constructedErrorMsg += "más de $minLengthBeforePoint dígitos antes del punto decimal";
    }
    else if (minLengthBeforePoint == null && maxLengthBeforePoint != null) {
      constructedErrorMsg += "menos de $maxLengthBeforePoint dígitos antes del punto decimal";
    }
    else if (minLengthBeforePoint != null && maxLengthBeforePoint != null) {
      constructedErrorMsg += "entre $minLengthBeforePoint y $maxLengthBeforePoint dígitos antes del punto decimal";
    }

    if (exactLengthBeforePoint != null && beforePoint.length != exactLengthBeforePoint!) {
      return constructedErrorMsg;
    }
    if (minLengthBeforePoint != null && beforePoint.length < minLengthBeforePoint!) {
      return constructedErrorMsg;
    }
    if (maxLengthBeforePoint != null && beforePoint.length > maxLengthBeforePoint!) {
      return constructedErrorMsg;
    }


    /// Check for length after point
    constructedErrorMsg = "Debería tener ";
    if (exactLengthAfterPoint != null) {
      constructedErrorMsg += "exactamente $exactLengthAfterPoint dígitos después del punto decimal";
    }
    if (minLengthAfterPoint != null && maxLengthAfterPoint == null) {
      constructedErrorMsg += "más de $minLengthAfterPoint dígitos después del punto decimal";
    }
    else if (minLengthAfterPoint == null && maxLengthAfterPoint != null) {
      constructedErrorMsg += "menos de $maxLengthAfterPoint dígitos después del punto decimal";
    }
    else if (minLengthAfterPoint != null && maxLengthAfterPoint != null) {
      constructedErrorMsg += "entre $minLengthAfterPoint y $maxLengthAfterPoint dígitos después del punto decimal";
    }

    if (exactLengthAfterPoint != null && afterPoint.length != exactLengthAfterPoint!) {
      return constructedErrorMsg;
    }
    if (minLengthAfterPoint != null && afterPoint.length < minLengthAfterPoint!) {
      return constructedErrorMsg;
    }
    if (maxLengthAfterPoint != null && afterPoint.length > maxLengthAfterPoint!) {
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