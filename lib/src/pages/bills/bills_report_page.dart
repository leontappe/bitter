import 'package:flutter/material.dart';

import 'bar_graph.dart';

class BillsReportPage extends StatefulWidget {
  const BillsReportPage({Key key}) : super(key: key);

  @override
  _BillsReportPageState createState() => _BillsReportPageState();
}

class _BillsReportPageState extends State<BillsReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
      ),
      body: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 768.0 ? 2 : 1,
        children: <Widget>[
          BarGraph(title: 'Einnahmen', subtitle: 'Monatlich'),
        ],
      ),
    );
  }
}
