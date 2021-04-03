import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'device_state.dart';
import 'device_status.dart';
import 'alert_builder.dart';

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit() : super(DeviceWaitConnectState());

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
    emit(DeviceWaitConnectState());
  }

  Future<void> connect(BuildContext context, BluetoothDevice device,
      ScanResult scanResult) async {
    bool isTimeout = false;

    // Try connecting to device
    AlertBuilder(context).showLoadingIndicator();
    emit(DeviceConnectingState());

    await device.connect(autoConnect: false).timeout(Duration(seconds: 5),
        onTimeout: () {
      isTimeout = true;
      device.disconnect();
      // Time out
      AlertBuilder(context).hideOpenDialog();
      // Todo: alert or notification about time out error
      emit(DeviceConnectedFailed(exception: "time out"));
    }).then((value) async {
      if (!isTimeout) {
        // Connected
        AlertBuilder(context).hideOpenDialog();
        emit(DeviceConnectedState(
            status: DeviceStatus.connected,
            device: device,
            scanResult: scanResult));

        // Discover service
        await discoverService(context, device, scanResult);
      }
    }).onError((error, stackTrace) {
      AlertBuilder(context).hideOpenDialog();
      emit(DeviceConnectedFailed(exception: error.toString()));
    });
  }

  Future<void> discoverService(BuildContext context, BluetoothDevice device,
      ScanResult scanResult) async {
    await device.discoverServices().then((services) {
      if (services.length > 0) {
        emit(DeviceConnectedState(
          status: DeviceStatus.connected,
          device: device,
          scanResult: scanResult,
          services: services,
        ));
      } else {
        emit(DeviceConnectedFailed(exception: "no service"));
      }
    }).onError((error, stackTrace) {
      emit(DeviceConnectedFailed(exception: error.toString()));
    });
  }
}
