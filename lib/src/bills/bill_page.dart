import 'package:flutter/material.dart';

import '../models/bill.dart';

class BillPage extends StatefulWidget {
  final Bill bill;

  BillPage({this.bill});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill.billNr),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(title: Text('Erstellt am ${widget.bill.created.toLocal()}')),
        ],
      ),
    );
  }
}
