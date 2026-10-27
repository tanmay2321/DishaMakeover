import 'package:intl/intl.dart';

class DateHelper {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _invoiceCodeFormat = DateFormat('yyyyMMdd');

  static String format(DateTime date) => _displayFormat.format(date);
  static String formatWithTime(DateTime date) => _dateTimeFormat.format(date);
  static String forInvoiceCode(DateTime date) => _invoiceCodeFormat.format(date);
}
