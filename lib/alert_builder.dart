import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertBuilder {
  AlertBuilder(this.context);
  final BuildContext context;

  void hideOpenDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void showLoadingIndicator() {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.0),
      context: context,
      builder: (BuildContext context) {
        return buildDeviceConnectingAlert();
      },
    );
  }

  void showTimeOutAlert() {
    showDialog(
        barrierDismissible: true,
        barrierColor: Colors.white.withOpacity(0.0),
        context: context,
        builder: (BuildContext context) {
          return buildTimeOutAlert();
        });
  }

  void showScanningIndicator() {
    showDialog(
        barrierDismissible: true,
        barrierColor: Colors.white.withOpacity(0.0),
        context: context,
        builder: (BuildContext context) {
          return buildScanningIndicator();
        });
  }

  void showErrorConnectionAlert(String error) {
    showDialog(
        barrierDismissible: true,
        barrierColor: Colors.white.withOpacity(0.0),
        context: context,
        builder: (BuildContext context) {
          return buildErrorConnect(error);
        });
  }

  CupertinoAlertDialog buildScanningIndicator() {
    return CupertinoAlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text("Connecting to the Peripheral"),
          )
        ],
      ),
    );
  }

  CupertinoAlertDialog buildTimeOutAlert() {
    return CupertinoAlertDialog(
      title: Text("Timeout"),
      content: Text("Connecting fail from the Peripheral"),
      actions: [
        TextButton(
            onPressed: () {
              hideOpenDialog();
            },
            child: Text("OK"))
      ],
    );
  }

  CupertinoAlertDialog buildErrorConnect(String error) {
    return CupertinoAlertDialog(
      title: Text("Exception"),
      content: Text("Failed to connect to the Peripheral \n $error"),
      actions: [
        TextButton(
            onPressed: () {
              hideOpenDialog();
            },
            child: Text("OK"))
      ],
    );
  }

  AlertDialog buildDeviceConnectingAlert() {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        backgroundColor: Colors.black.withOpacity(0.7),
        content: Container(
          color: Colors.black.withOpacity(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "Connecting to the Peripheral",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ));
  }
}
