import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble_scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  ScanCubit() : super(WaitToScanState());

  void stop() {
    List<BluetoothDevice> devices = [];
    List<ScanResult> devicesInfo = [];

    flutterBlue.stopScan();
    emit(
      ScannedState(devices: devices, devicesInfo: devicesInfo),
    );
  }

  Future<void> scan() async {
    List<BluetoothDevice> devices = [];
    List<ScanResult> devicesInfo = [];
    // Start scan
    emit(ScanningState());
    // Wait few second
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      print("found ${results.length} ${results.toString()}");
      for (ScanResult result in results) {
        final BluetoothDevice device = result.device;
        if (!devices.contains(device)) {
          devicesInfo.add(result);
          devices.add(result.device);
          emit(ScannedState(devices: devices, devicesInfo: devicesInfo));
        }
      }
    });
    // Update found device
    // emit(ScannedState(devices: devices, devicesInfo: devicesInfo));
  }
}
