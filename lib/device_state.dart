import 'package:flutter_blue/flutter_blue.dart';
import 'device_status.dart';

abstract class DeviceState {}

class DeviceWaitConnectState extends DeviceState {}

class DeviceConnectingState extends DeviceState {}

class DeviceConnectedState extends DeviceState {
  final DeviceStatus status;
  final BluetoothDevice device;
  final List<BluetoothService> services;

  DeviceConnectedState(
      {required this.status, required this.device, this.services = const []});
}
