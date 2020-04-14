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

  bool searchEnabled = false;

  List<Bill> bills = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !searchEnabled,
        title: searchEnabled
            ? TextField(
                autofocus: true,
                maxLines: 1,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    hintText: 'Suchbegriff',
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: Colors.white), onPressed: onToggleSearch)),
                onChanged: onSearchChanged,
              )
            : Text('Rechnungen'),
        actions: <Widget>[
          if (!searchEnabled) ...[
            IconButton(icon: Icon(Icons.search), onPressed: onToggleSearch),
          ],
        ],
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

  Future<void> onSearchChanged(String value) async {
    bills = await billRepo.select(searchQuery: value);
    setState(() => bills);
  }

  void onToggleSearch() async {
    setState(() {
      if (searchEnabled) {
        searchEnabled = false;
      } else {
        searchEnabled = true;
      }
    });

    if (!searchEnabled) {
      await onGetBills();
    }
  }
}
