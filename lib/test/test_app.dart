import 'package:flutter/material.dart';
import 'package:flutter_ble/main.dart';

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Test"),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.green[200],
              height: 50,
              child: ListTile(
                title: Text("Device ID"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
