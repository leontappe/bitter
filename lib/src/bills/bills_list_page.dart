import 'package:flutter/material.dart';

import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/bill_repository.dart';
import 'bill_page.dart';
import 'save_bill_button.dart';

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
                      tooltip: 'Suchleiste deaktivieren',
                      icon: Icon(Icons.clear, color: Colors.white),
                      onPressed: onToggleSearch,
                    )),
                onChanged: onSearchChanged,
              )
            : Text('Rechnungen'),
        actions: <Widget>[
          if (!searchEnabled) ...[
            IconButton(
              tooltip: 'Suchleiste aktivieren',
              icon: Icon(Icons.search),
              onPressed: onToggleSearch,
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        child: ListView(
          children: <Widget>[
            ...bills.reversed.map(
              (Bill b) => ListTile(
                title: Text(b.billNr),
                subtitle: Text(b.created.toString().split('.').first),
                trailing: SaveBillButton(bill: b),
                onTap: () => Navigator.push<bool>(context,
                    MaterialPageRoute(builder: (BuildContext context) => BillPage(bill: b))),
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
