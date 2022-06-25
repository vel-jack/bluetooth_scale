import 'dart:io';

class Singleton {
  static final _instance = Singleton._private();
  Singleton._private();
  factory Singleton() => _instance;
  String name = '';
  String email = '';
  String business = '';
  String phone = '';
  File? profileImage;
  double limit = 600.0;
}
