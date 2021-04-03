import 'package:flutter/material.dart';

class AlertBuilder {
  AlertBuilder(this.context);
  final BuildContext context;

  void hideOpenDialog() {
    Navigator.of(context).pop();
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
