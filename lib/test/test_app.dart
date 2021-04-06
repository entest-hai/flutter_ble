import 'package:flutter/material.dart';
import 'package:flutter_ble/alert_builder.dart';

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AlertProgressView());
  }
}

// Show alert with circular progress indicator
class AlertProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alert"),
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              child: Text("Alert"),
              onPressed: () async {
                AlertBuilder(context).showErrorConnectionAlert("Unknown");
                // AlertBuilder(context).showScanningIndicator();
                // AlertBuilder(context).showTimeOutAlert();
                // await Future.delayed(Duration(seconds: 5));
                // AlertBuilder(context).hideOpenDialog();
              },
            ),
          )
        ],
      ),
    );
  }
}

// List of different item type
class ListOfListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = createListCard();

    return Scaffold(
      appBar: AppBar(
        title: Text("List"),
      ),
      body: ListView(
        children: items.map((e) => e.buildCard(context)).toList(),
      ),
    );
  }

  List<ListItem> createListCard() {
    List<String> data = ["Service 1", "Service 2", "Service 3"];
    return List<ListItem>.generate(
        data.length,
        (index) => index % 2 == 0
            ? HeadingItem(data[index])
            : MessageItem(data[index]));
  }
}

abstract class ListItem {
  Widget buildCard(BuildContext context);
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
}

class HeadingItem extends ListItem {
  final String heading;
  HeadingItem(this.heading);

  Widget buildCard(BuildContext context) {
    return Card(
      color: Colors.green[200],
      child: ListTile(
        title: Text(heading),
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget buildSubtitle(BuildContext context) => Container();
}

class MessageItem extends ListItem {
  final String message;
  MessageItem(this.message);

  Widget buildCard(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(message),
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Text(message);
  }

  Widget buildSubtitle(BuildContext context) {
    return Text(message);
  }
}
