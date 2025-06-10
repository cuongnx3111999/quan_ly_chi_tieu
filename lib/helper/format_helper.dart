import 'package:intl/intl.dart';

class FormatHelper {
  String formatMoney(num? value, [String? unit]) {
    if (value == null) {
      return "";
    }

    NumberFormat formatter;
    if (value is int) {
      formatter = NumberFormat("#,###");
    } else {
      formatter = NumberFormat("#,###.###");
    }

    String output = formatter.format(value);
    if (unit != null) output += unit;
    return output;
  }
}
