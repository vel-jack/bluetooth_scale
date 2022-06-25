import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

part 'devices_state.dart';

class DevicesListCubit extends Cubit<DevicesListState> {
  DevicesListCubit() : super(ListLoading()) {
    getPairedDevices();
  }

  Future<void> getPairedDevices() async {
    try {
      await FlutterBluetoothSerial.instance.getBondedDevices().then((value) {
        emitLoadedList(value);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void emitLoadedList(List<BluetoothDevice> value) {
    var loading = List.generate(value.length, ((index) => false));
    emit(ListLoaded(value, loading));
  }
}
