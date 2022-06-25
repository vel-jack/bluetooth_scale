import 'package:bluetooth_scale/logic/ble_devices/devices_cubit.dart';
import 'package:bluetooth_scale/logic/ble_status/ble_status_cubit.dart';
import 'package:bluetooth_scale/logic/connection/ble_cnx_cubit.dart';
import 'package:bluetooth_scale/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BleStatusCubit>(create: (context) => BleStatusCubit()),
        BlocProvider<DevicesListCubit>(create: (context) => DevicesListCubit()),
        BlocProvider<ConnectionCubit>(
            create: (context) => ConnectionCubit(
                bleStatusCubit: BlocProvider.of<BleStatusCubit>(context)))
      ],
      child: MaterialApp(
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
        home: const SplashScreen(),
      ),
    );
  }
}
