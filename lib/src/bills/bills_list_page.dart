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
                leading: (b.status == BillStatus.unpaid && DateTime.now().isAfter(b.dueDate))
                    ? Icon(Icons.euro_symbol, color: Colors.red)
                    : (b.status == BillStatus.cancelled)
                        ? Icon(Icons.cancel, color: Colors.red)
                        : (b.status == BillStatus.paid)
                            ? Icon(Icons.check, color: Colors.green)
                            : Icon(Icons.euro_symbol, color: Colors.orange),
                title: Text(b.billNr),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Bearbeiter*in: ${b.editor}, ${b.vendor.name} - Kunde*in: ${b.customer.name} ${b.customer.surname}'),
                    Text('Rechnungsdatum: ${b.created.day}.${b.created.month}.${b.created.year}')
                  ],
                ),
                trailing: SaveBillButton(bill: b),
                onTap: () => onPushBillPage(b.id),
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

  Future<void> onPushBillPage(int id) async {
    if (await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (BuildContext context) => BillPage(id: id)))) {
      await onGetBills();
    }
  }
}
