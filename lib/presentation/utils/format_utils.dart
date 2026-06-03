import 'package:intl/intl.dart';

class FormatUtils {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatIdr(double value) {
    return _currencyFormatter.format(value);
  }

  static String formatIdrSigned(double value, {required bool isPositive}) {
    final sign = isPositive ? '+ ' : '- ';
    return '$sign${_currencyFormatter.format(value)}';
  }
}
