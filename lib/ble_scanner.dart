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
    return BlocBuilder<DeviceCubit, DeviceState>(builder: (context, state) {
      return Navigator(
        pages: [
          MaterialPage(child: ScannerView()),
          if (state is DeviceConnectedState) MaterialPage(child: DeviceView())
        ],
        onPopPage: (route, result) {
          return route.didPop(result);
        },
      );
    });
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
            title: Text("Device"),
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
                              "UUID: ${state.devicesInfo[index].device.id}, name: ${state.devicesInfo[index].device.name}, RSSI: ${state.devicesInfo[index].rssi},  adv: ${state.devicesInfo[index].advertisementData.toString()} ${state.devicesInfo[index].advertisementData.serviceUuids}"),
                        )),
                        ElevatedButton(
                            onPressed: () async {
                              BlocProvider.of<DeviceCubit>(context).connect(
                                  context,
                                  state.devices[index],
                                  state.devicesInfo[index]);
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
                        ElevatedButton(onPressed: () {}, child: Text("Connect"))
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
      return Scaffold(
        appBar: AppBar(
          title: state is DeviceConnectedState
              ? Text("${state.device.name} ${state.device.state.toString()}")
              : Text("N/A ${state.toString()}"),
        ),
        body: BlocBuilder<DeviceCubit, DeviceState>(
          builder: (context, state) {
            if (state is DeviceWaitConnectState) {
              return Container();
            } else if (state is DeviceConnectingState) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is DeviceConnectedState) {
              return Container(
                child: Column(
                  children: [
                    Expanded(
                        child: ListView(
                      children: [
                        Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              "Device UUID: ${state.device.id} name: ${state.device.name} Status: ${state.status}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ...ScanResultCard(scanResult: state.scanResult)
                            .buildCard(context),
                        for (var service in state.services)
                          ...ServiceCard(service).buildCard(context)
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
          },
        ),
      );
    });
  }
}

class ScanResultCard {
  final ScanResult scanResult;
  ScanResultCard({required this.scanResult});

  List<Widget> buildCard(BuildContext context) {
    return [
      Card(
        color: Colors.green[200],
        child: ListTile(
          title: Text("ADVERTIMENT DATA"),
        ),
      ),
      Card(
        child: ListTile(
          title: Text("local name: ${scanResult.advertisementData.localName}"),
        ),
      ),
      Card(
        child: ListTile(
          title: Text("txPower ${scanResult.advertisementData.txPowerLevel}"),
        ),
      ),
      for (var serviceUUID in scanResult.advertisementData.serviceUuids)
        Card(
          child: ListTile(
              title: Text("service $serviceUUID ${serviceUUID.toString()}")),
        )
    ];
  }
}

class ServiceCard {
  final BluetoothService service;
  ServiceCard(this.service);

  List<Widget> buildCard(BuildContext context) {
    return [
      Card(
        color: Colors.green[200],
        child: ListTile(
          title: Text("Service UUID: ${service.uuid.toString()}"),
        ),
      ),
      for (var char in service.characteristics)
        Card(
          color: Colors.white,
          child: ListTile(
            title: Text("Char UUID: ${char.uuid.toString()}"),
          ),
        )
    ];
  }
}
