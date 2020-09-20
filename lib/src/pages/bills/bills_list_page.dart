import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../repositories/settings_repository.dart';
import 'bill_list_tile.dart';
import 'bill_page.dart';

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

  bool _groupedMode = true;

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
              icon: Icon(Icons.dehaze, color: _groupedMode ? null : Colors.green[200]),
              onPressed: () => setState(() => _groupedMode = !_groupedMode),
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
            if (_groupedMode)
              Column(
                children: [
                  ListTile(title: Text('Überfällig', style: Theme.of(context).textTheme.headline4)),
                  ...bills
                      .where((Bill b) =>
                          (((b.reminders == null || b.reminders.isEmpty) &&
                                  DateTime.now().isAfter(b.dueDate)) ||
                              (b.reminders != null &&
                                  b.reminders.isNotEmpty &&
                                  DateTime.now().isAfter(b.reminders.last.deadline))) &&
                          b.status == BillStatus.unpaid)
                      .map(
                        (Bill b) => BillListTile(
                          bill: b,
                          onTap: () => onPushBillPage(b.id),
                        ),
                      ),
                  Divider(),
                  ListTile(title: Text('Laufend', style: Theme.of(context).textTheme.headline4)),
                  ...bills
                      .where((Bill b) =>
                          b.status == BillStatus.unpaid &&
                          (DateTime.now().isBefore(b.dueDate) ||
                              (b.reminders.isNotEmpty &&
                                  DateTime.now().isBefore(b.reminders.last.deadline))))
                      .map(
                        (Bill b) => BillListTile(
                          bill: b,
                          onTap: () => onPushBillPage(b.id),
                        ),
                      ),
                  Divider(),
                  ListTile(
                      title: Text('Abgeschlossen oder storniert',
                          style: Theme.of(context).textTheme.headline4)),
                  ...bills
                      .where((Bill b) =>
                          b.status == BillStatus.paid || b.status == BillStatus.cancelled)
                      .map(
                        (Bill b) => BillListTile(
                          bill: b,
                          onTap: () => onPushBillPage(b.id),
                        ),
                      ),
                ],
              )
            else
              ...bills.map(
                (Bill b) => BillListTile(
                  bill: b,
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
    bills.sort((Bill a, Bill b) => b.created.compareTo(a.created));
    if (mounted) setState(() => bills);
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
