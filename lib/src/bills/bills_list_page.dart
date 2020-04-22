import 'package:bitter/src/models/vendor.dart';
import 'package:bitter/src/repositories/settings_repository.dart';
import 'package:flutter/material.dart';

import '../providers/database_provider.dart';
import '../providers/inherited_database.dart';
import '../repositories/bill_repository.dart';
import 'bill_page.dart';
import 'save_bill_button.dart';

class BillsListPage extends StatefulWidget {
  @override
  _BillsListPageState createState() => _BillsListPageState();
}

class _BillsListPageState extends State<BillsListPage> {
  BillRepository<DatabaseProvider> billRepo;
  SettingsRepository settings;

  bool searchEnabled = false;

  List<Bill> bills = [];
  List<Vendor> vendors = [];
  int filterVendor;
  String searchQuery;

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
            DropdownButton<int>(
              value: filterVendor,
              dropdownColor: Colors.grey[800],
              iconEnabledColor: Colors.white70,
              style:
                  TextStyle(color: Colors.white, decorationColor: Colors.white70, fontSize: 14.0),
              hint: Text('Nach Verkäufer filtern', style: TextStyle(color: Colors.white)),
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem(child: Text('Filter zurücksetzen'), value: -1),
                ...vendors.map((Vendor v) => DropdownMenuItem(value: v.id, child: Text(v.name)))
              ],
              onChanged: onFilter,
            ),
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
    billRepo = BillRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    settings = SettingsRepository();
    await billRepo.setUp();
    await settings.setUp();

    await onGetBills();

    filterVendor = settings.select<int>('bills_filter');

    await onGetBills();
  }

  Future<void> onFilter(int value) async {
    if (value >= 0) {
      filterVendor = value;
    } else {
      filterVendor = null;
    }
    await onGetBills();
    await settings.insert('bills_filter', filterVendor);
  }

  Future<void> onGetBills() async {
    bills = await billRepo.select(searchQuery: searchQuery, vendorFilter: filterVendor);
    if (filterVendor == null) {
      for (var bill in bills) {
        if (!vendors.contains(bill.vendor)) {
          vendors.add(bill.vendor);
        }
      }
    }
    setState(() => bills);
    return;
  }

  Future<void> onPushBillPage(int id) async {
    if (await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (BuildContext context) => BillPage(id: id)))) {
      await onGetBills();
    }
  }

  Future<void> onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      searchQuery = value;
    } else {
      searchQuery = null;
    }
    await onGetBills();
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
