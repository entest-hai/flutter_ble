import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
// scan state and cubit
import 'ble_scan_state.dart';
import 'ble_scan_cubit.dart';

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
                icon: Icon(
                  Icons.stop,
                  color: Colors.red,
                ),
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
