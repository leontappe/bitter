import 'package:bitter/src/repositories/vendor_repository.dart';
import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/settings_repository.dart';
import 'item_page.dart';

class ItemsListPage extends StatefulWidget {
  @override
  _BillsListPageState createState() => _BillsListPageState();
}

class _BillsListPageState extends State<ItemsListPage> {
  ItemRepository<DatabaseProvider> repo;
  VendorRepository<DatabaseProvider> vendorRepo;
  SettingsRepository settings;

  bool searchEnabled = false;

  List<Item> items = [];
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
            : Text('Artikel'),
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
            IconButton(
              tooltip: 'Neuen Artikel erstellen',
              icon: Icon(Icons.note_add),
              onPressed: onPushItemPage,
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        child: ListView(
          children: <Widget>[
            ...items.reversed.map(
              (Item i) => ListTile(
                leading: Text(vendors.singleWhere((Vendor v) => v.id == i.vendor).billPrefix +
                    '\nA' +
                    i.itemId.toString()),
                title: Text(i.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (i.description != null) Text('Beschreibung: ${i.description}'),
                    Text('Steuer: ${i.tax} %'),
                  ],
                ),
                trailing: Text('${(i.price / 100.0).toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.subtitle1),
                onTap: () => onPushItemPage(item: i),
              ),
            ),
          ],
        ),
        onRefresh: () => onGetItems(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = ItemRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    settings = SettingsRepository();
    await repo.setUp();
    await vendorRepo.setUp();
    await settings.setUp();

    await onGetItems();

    filterVendor = settings.select<int>('items_filter');

    await onGetItems();
  }

  Future<void> onFilter(int value) async {
    if (value >= 0) {
      filterVendor = value;
    } else {
      filterVendor = null;
    }
    await onGetItems();
    await settings.insert('items_filter', filterVendor);
  }

  Future<void> onGetItems() async {
    items = await repo.select(searchQuery: searchQuery, vendorFilter: filterVendor);
    if (filterVendor == null) {
      for (var item in items) {
        final vendor = await vendorRepo.selectSingle(item.vendor);
        if (!vendors.contains(vendor)) {
          vendors.add(vendor);
        }
      }
    }
    setState(() => items);
    return;
  }

  Future<void> onPushItemPage({Item item}) async {
    if (await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (BuildContext context) => ItemPage(item: item)))) {
      await onGetItems();
    }
  }

  Future<void> onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      searchQuery = value;
    } else {
      searchQuery = null;
    }
    await onGetItems();
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
      await onGetItems();
    }
  }
}
