import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  static final NumberFormat _inrFormatterDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static String format(double amount, {bool showDecimals = false}) {
    if (showDecimals && amount % 1 != 0) {
      return _inrFormatterDecimals.format(amount);
    }
    return _inrFormatter.format(amount);
  }

  static String formatPlain(double amount) {
    return '₹ ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
  }
}
