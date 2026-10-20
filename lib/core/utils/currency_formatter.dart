import 'package:flutter/services.dart';

class CurrencyFormatter {
  /// Format angka menjadi format mata uang Rupiah dengan pemisah ribuan titik.
  /// Contoh:
  /// - 1000 -> "Rp 1.000" (withSymbol: true) atau "1.000" (withSymbol: false)
  /// - 10000 -> "Rp 10.000"
  /// - 100000 -> "Rp 100.000"
  static String format(num? value, {bool withSymbol = true}) {
    if (value == null) return withSymbol ? 'Rp 0' : '0';

    final isNegative = value < 0;
    final absVal = value.abs();

    // Pisahkan bilangan bulat dan desimal jika ada
    final parts = absVal.toString().split('.');
    final intPart = parts[0];

    final buffer = StringBuffer();
    final len = intPart.length;

    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    String formatted = buffer.toString();

    // Jika ada desimal dan bukan .0
    if (parts.length > 1 && parts[1] != '0' && parts[1].isNotEmpty) {
      formatted += ',${parts[1]}';
    }

    final sign = isNegative ? '-' : '';
    return withSymbol ? '${sign}Rp $formatted' : '$sign$formatted';
  }

  /// Format khusus hanya angka dengan pemisah ribuan titik (contoh: "100.000", "10.000", "1.000")
  static String formatNumber(num? value) {
    return format(value, withSymbol: false);
  }

  /// Helper untuk memformat string atau angka mentah
  static String formatDynamic(dynamic value, {bool withSymbol = true}) {
    if (value == null) return withSymbol ? 'Rp 0' : '0';
    if (value is num) return format(value, withSymbol: withSymbol);
    final parsed = num.tryParse(
      value.toString().replaceAll(RegExp(r'[^0-9.-]'), ''),
    );
    return format(parsed ?? 0, withSymbol: withSymbol);
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ambil angka saja, tanpa titik, koma, atau karakter lainnya.
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Hitung jumlah digit sebelum posisi kursor.
    final cursorPosition = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );

    final digitsBeforeCursor = newValue.text
        .substring(0, cursorPosition)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    // Format angka dengan pemisah ribuan berupa titik.
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    // Tentukan kembali posisi kursor setelah pemformatan.
    var newCursorPosition = 0;
    var digitCount = 0;

    while (newCursorPosition < formatted.length &&
        digitCount < digitsBeforeCursor) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newCursorPosition])) {
        digitCount++;
      }
      newCursorPosition++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
