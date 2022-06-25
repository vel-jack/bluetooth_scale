import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

part 'ble_status_state.dart';

class BleStatusCubit extends Cubit<BleState> {
  BleStatusCubit() : super(BleStatusLoading()) {
    updateStatus();
  }
  void emitOn() => emit(BleOnState());
  void emitOff() => emit(BleOffState());
  updateStatus() {
    FlutterBluetoothSerial.instance.state.then((event) {
      if (event == BluetoothState.STATE_ON) {
        emitOn();
      } else if (event == BluetoothState.STATE_OFF) {
        emitOff();
      }
    });
  }
}
