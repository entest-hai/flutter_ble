import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => BluetoothCubit()),
          BlocProvider(create: (context) => ScanCubit())
        ],
        child: ScannNavigator(),
      ),
    );
  }
}

class ScannNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [MaterialPage(child: ScannerView())],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}

class ScannerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (c, snapshot) {
        // final state = snapshot.data;
        final state = BluetoothState.on;

        if (state == BluetoothState.on) {
          return ScanDevicesView();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Scanner"),
          ),
          body: Center(
            child: Text("BLE UNKNOW"),
          ),
        );
      },
    );
  }
}

class ScanDevicesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            BlocProvider.of<ScanCubit>(context).scan();
          },
          child: Icon(Icons.bluetooth_searching),
        ),
        appBar: AppBar(
          title: Text("Scanner"),
          actions: [
            IconButton(
                icon: Icon(Icons.stop),
                onPressed: () {
                  BlocProvider.of<ScanCubit>(context).stop();
                })
          ],
        ),
        body: BlocBuilder<ScanCubit, ScanState>(builder: (context, state) {
          if (state is ScanningState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ScannedState) {
            return ListView.builder(
                itemCount: state.devices.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(state.devicesInfo[index].toString()),
                      // "${state.devicesInfo[index].device.id} ${state.devicesInfo[index].device.name} ${state.devicesInfo[index].rssi}"),
                    ),
                  );
                });
          } else {
            return Container(
              color: Colors.white,
            );
          }
        }));
  }
}

// BluetoothState  and BluetoothCubit
class BluetoothCubit extends Cubit<BluetoothState> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCubit() : super(BluetoothState.unknown);
}

// Discovered Devices State and Cubit
abstract class ScanState {}

class WaitToScanState extends ScanState {}

class ScanningState extends ScanState {}

class ScannedState extends ScanState {
  final List<BluetoothDevice> devices;
  final List<ScanResult> devicesInfo;
  ScannedState({required this.devices, required this.devicesInfo});
}

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
    flutterBlue.startScan(timeout: Duration(seconds: 2));
    flutterBlue.scanResults.listen((results) {
      print("found ${results.length}");
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
  }
}
