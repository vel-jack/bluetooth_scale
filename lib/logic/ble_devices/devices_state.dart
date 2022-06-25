part of 'devices_cubit.dart';

abstract class DevicesListState {}

class ListLoading extends DevicesListState {}

class ListLoaded extends DevicesListState {
  List<BluetoothDevice> devices = [];
  List<bool> isLoading = [];
  ListLoaded(this.devices, this.isLoading);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListLoaded && other.devices == devices;
  }

  @override
  int get hashCode => devices.hashCode;
}
