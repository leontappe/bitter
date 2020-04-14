import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/bill_repository.dart';

class BillsListPage extends StatefulWidget {
  @override
  _BillsListPageState createState() => _BillsListPageState();
}

class _BillsListPageState extends State<BillsListPage> {
  BillRepository<MySqlProvider> billRepo;

  List<Bill> bills = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechnungen'),
      ),
      body: RefreshIndicator(
        child: ListView(
          children: <Widget>[
            ...bills.reversed.map(
              (Bill b) => ListTile(
                title: Text(b.billNr),
                subtitle: Text(b.created.toLocal().toString().split('.').first),
                trailing:
                    IconButton(icon: Icon(Icons.file_download), onPressed: () => onSaveBill(b)),
              ),
            ),
          ],
        ),
        onRefresh: () async => await onGetBills(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    billRepo = BillRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    await billRepo.setUp();

    await onGetBills();
  }

  Future<void> onGetBills() async {
    bills = await billRepo.select();
    setState(() => bills);
    return;
  }

  Future<void> onSaveBill(Bill bill) async {
    String downloadsPath;
    if (Platform.isWindows) {
      downloadsPath = (await getApplicationDocumentsDirectory()).path;
    } else {
      downloadsPath = (await getDownloadsDirectory()).path;
    }
    final file = File('${downloadsPath}/bitter/${bill.billNr}.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(bill.file);
  }
}
