import 'package:flutter/services.dart';


class FloatingPointTextInputFormatter extends TextInputFormatter {
  final int? maxDigitsBeforeDecimal;
  final int? maxDigitsAfterDecimal;

  FloatingPointTextInputFormatter({
    this.maxDigitsBeforeDecimal,
    this.maxDigitsAfterDecimal,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Allow leading decimal
    String sanitizedText = text.startsWith('.') ? '0$text' : text;

    final parts = sanitizedText.split('.');

    // Validate digits before decimal
    if (maxDigitsBeforeDecimal != null && parts[0].length > maxDigitsBeforeDecimal!) {
      return oldValue;
    }

    // Validate digits after decimal
    if (maxDigitsAfterDecimal != null && parts.length > 1 && parts[1].length > maxDigitsAfterDecimal!) {
      return oldValue;
    }

    // Allow only digits and optional decimal point
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(sanitizedText)) {
      return oldValue;
    }

    return newValue;
  }
}