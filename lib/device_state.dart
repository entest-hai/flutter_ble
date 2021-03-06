import 'package:flutter_blue/flutter_blue.dart';
import 'device_status.dart';

abstract class DeviceState {}

class DeviceWaitConnectState extends DeviceState {}

class DeviceConnectingState extends DeviceState {}

class DeviceConnectedFailed extends DeviceState {
  final String exception;
  DeviceConnectedFailed({required this.exception});
}

class DeviceConnectedState extends DeviceState {
  final DeviceStatus status;
  final BluetoothDevice device;
  final ScanResult scanResult;
  final List<BluetoothService> services;

  DeviceConnectedState(
      {required this.status,
      required this.device,
      required this.scanResult,
      this.services = const []});
}
