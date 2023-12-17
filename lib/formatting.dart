import 'package:intl/intl.dart';

final formatter = DateFormat.yMMMMd();

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }
}

class CustomDateFormat {
  static String convertToDateTime(DateTime date) {
    return formatter.format(date);
  }
}
