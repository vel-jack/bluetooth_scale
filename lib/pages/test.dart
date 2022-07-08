// ignore_for_file: avoid_print

import 'package:intl/intl.dart';

void main() {
  print(compact(1212313301));
}

String compact(int n) {
  return NumberFormat.compact().format(n);
}
