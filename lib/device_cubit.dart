import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'device_state.dart';
import 'device_status.dart';

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit() : super(DeviceWaitConnectState());

  Future<void> connect(BluetoothDevice device) async {
    bool isTimeout = false;

    // Try connecting to device
    emit(DeviceConnectingState());

    await device.connect(autoConnect: false).timeout(Duration(seconds: 5),
        onTimeout: () {
      isTimeout = true;

      device.disconnect();
      // Time out
      emit(DeviceConnectedState(status: DeviceStatus.timeout, device: device));
    }).then((value) async {
      if (!isTimeout) {
        // Connected
        emit(DeviceConnectedState(
            status: DeviceStatus.connected, device: device));

        // Discover service
        await discoverService(device);
      }
    }).onError((error, stackTrace) {
      emit(DeviceConnectedState(
          status: DeviceStatus.unconnected, device: device));
    });
  }

  Future<void> discoverService(BluetoothDevice device) async {
    await device.discoverServices().then((services) {
      if (services.length > 0) {
        emit(DeviceConnectedState(
            status: DeviceStatus.connected,
            device: device,
            services: services));
      } else {
        emit(DeviceConnectedState(
            status: DeviceStatus.connected_found_zero_service, device: device));
      }
    }).onError((error, stackTrace) {
      emit(DeviceConnectedState(
          status: DeviceStatus.connected_failed_found_service, device: device));
    });
  }
}
