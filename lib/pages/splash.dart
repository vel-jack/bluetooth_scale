import 'dart:async';
import 'package:bluetooth_scale/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      Get.to(() => const HomePage());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Image(
            image: AssetImage('assets/bioz.png'),
            width: 100,
            height: 100,
          ),
          SizedBox(height: 20),
          SizedBox(width: 35, child: LinearProgressIndicator())
        ],
      ),
    );
  }
}
