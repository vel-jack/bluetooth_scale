import 'dart:async';
import 'dart:io';
import 'package:bluetooth_scale/pages/user/edit_profile.dart';
import 'package:bluetooth_scale/utils/blue_singleton.dart';
import 'package:bluetooth_scale/pages/select_device.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      Singleton().name = value.getString('name') ?? 'BIOZ';
      Singleton().phone = value.getString('number') ?? '';
      Singleton().email = value.getString('email') ?? '';
      Singleton().business = value.getString('business') ?? 'BIOZ';
      Singleton().limit = value.getDouble("limit") ?? 600.0;
      if (value.getString('imgPath') != null) {
        Singleton().profileImage = File(value.getString('imgPath')!);
      }
    });
    Timer(const Duration(seconds: 2), () {
      if (Singleton().phone == '' || Singleton().email == '') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const EditPofile(
                      fromSplash: true,
                    )));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SelectDevice()));
      }
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
