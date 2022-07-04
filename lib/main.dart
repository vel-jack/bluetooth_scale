import 'package:bluetooth_scale/controller/bluetooth_controller.dart';
import 'package:bluetooth_scale/controller/customer_controller.dart';
import 'package:bluetooth_scale/controller/owner_controller.dart';
import 'package:bluetooth_scale/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Get.put(BluetoothController());
  Get.put(OwnerController());
  Get.put(CustomerController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BScale',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Nunito',
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0),
          scaffoldBackgroundColor: Colors.white),
      home: const HomePage(),
    );
  }
}
