import 'package:bitter/src/providers/inherited_database.dart';
import 'package:bitter/src/repositories/bill_repository.dart';
import 'package:flutter/material.dart';

import 'bar_graph.dart';

class BillsReportPage extends StatefulWidget {
  const BillsReportPage({Key key}) : super(key: key);

  @override
  _BillsReportPageState createState() => _BillsReportPageState();
}

class _BillsReportPageState extends State<BillsReportPage> {
  BillRepository _billRepo;

  bool busy;

  List<Bill> _bills;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
      ),
      body: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 768.0 ? 2 : 1,
        children: <Widget>[
          BarGraph(
            title: 'Einnahmen',
            subtitle: 'Monatlich',
            data: {'Juni': 300},
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Map<String, double> generateMonthlyReport({int length = 6}) {
    Map<String, double> report = {};
    final currentMonth = DateTime.now().month;

    /*for (int month = currentMonth; i > currentMonth - length; i--) {
      _bills.where((Bill e) => e.created.month == month);
      report.addAll({});
    }*/
  }

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    if (mounted) setState(() => busy = true);

    _billRepo = BillRepository(InheritedDatabase.of(context));
    await _billRepo.setUp();

    _bills = await _billRepo.select();

    if (mounted) setState(() => busy = false);
  }
}
