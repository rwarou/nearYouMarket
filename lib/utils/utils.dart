import 'package:intl/intl.dart';

class utils {
  static final oCcy = new NumberFormat("#,###", "ko_KR");
  static String calcStringToWon(String price) {
    if (!RegExp('[0-9]').hasMatch(price)) {
      return price;
    }
    return "${oCcy.format(int.parse(price))}원";
  }
}
