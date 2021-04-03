import 'package:flutter_blue/flutter_blue.dart';

// Discovered Devices State and Cubit
abstract class ScanState {}

class WaitToScanState extends ScanState {}

class ScanningState extends ScanState {}

class ScannedState extends ScanState {
  final List<BluetoothDevice> devices;
  final List<ScanResult> devicesInfo;
  ScannedState({required this.devices, required this.devicesInfo});
}