import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
// scan state and cubit
import 'ble_scan_state.dart';
import 'ble_scan_cubit.dart';
// device state and cubit
import 'device_state.dart';
import 'device_cubit.dart';

class ScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ScanCubit()),
          BlocProvider(create: (context) => DeviceCubit())
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
                    child: Row(
                      children: [
                        Expanded(
                            child: ListTile(
                          title: Text(
                              "UUID: ${state.devicesInfo[index].device.id}, name: ${state.devicesInfo[index].device.name}, RSSI: ${state.devicesInfo[index].rssi},  manufacture: ${state.devicesInfo[index].advertisementData.manufacturerData}"),
                        )),
                        ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DeviceView();
                                  });
                              BlocProvider.of<DeviceCubit>(context)
                                  .connect(state.devices[index]);
                            },
                            child: Text("Connect"))
                      ],
                    ),
                  );
                });
          } else {
            return ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) {
                  return Card(
                    child: Row(
                      children: [
                        Expanded(
                            child: ListTile(
                          title: Text("very long device information "),
                        )),
                        ElevatedButton(
                            onPressed: () {
                              // BlocProvider.of<DeviceCubit>(context).connect();
                            },
                            child: Text("Connect"))
                      ],
                    ),
                  );
                });
          }
        }));
  }
}

class DeviceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(builder: (context, state) {
      if (state is DeviceWaitConnectState) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
        );
      } else if (state is DeviceConnectingState) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is DeviceConnectedState) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 50,
                child: ListTile(
                  title: Text(
                    "Device UUID: ${state.device.id} name: ${state.device.name}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                  child: ListView(
                children: [
                  ListTile(
                    tileColor: Colors.green[200],
                    title: Text(
                      "Status: ${state.status}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...state.services.map((service) => ListTile(
                        title: Text("${service.uuid.toString()}"),
                      )),
                ],
              )),
            ],
          ),
        );
      } else {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
        );
      }
    });
  }
}
