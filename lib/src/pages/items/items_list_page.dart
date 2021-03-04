import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../util.dart';
import '../../widgets/database_error_watcher.dart';
import 'item_page.dart';

class ItemsListPage extends StatefulWidget {
  @override
  _BillsListPageState createState() => _BillsListPageState();
}

class _BillsListPageState extends State<ItemsListPage> {
  ItemRepository repo;
  VendorRepository vendorRepo;
  SettingsRepository settings;

  bool searchEnabled = false;

  List<Item> items = [];
  List<Vendor> filterVendors = [];
  int filterVendor;
  String searchQuery;

  bool busy = false;

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
                DropdownMenuItem(
                  value: -1,
                  child: Text('Filter zurücksetzen'),
                ),
                ...filterVendors
                    .map((Vendor v) => DropdownMenuItem(value: v.id, child: Text(v.name))),
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
              icon: Icon(Icons.add),
              onPressed: onPushItemPage,
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => onGetItems(),
        child: DatabaseErrorWatcher(
          child: (busy)
              ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
              : ListView(
                  children: <Widget>[
                    ...items.map(
                      (Item i) {
                        final itemVendors = filterVendors.where((Vendor v) => v.id == i.vendor);
                        return ListTile(
                          leading: (itemVendors.isNotEmpty)
                              ? Text(itemVendors.first.billPrefix + '\nA' + i.itemId.toString())
                              : null,
                          title: Text(i.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (i.description != null) Text('Beschreibung: ${i.description}'),
                              Text('Steuer: ${i.tax} %'),
                            ],
                          ),
                          trailing: Text('${formatFigure(i.price)}',
                              style: Theme.of(context).textTheme.subtitle1),
                          onTap: () => onPushItemPage(item: i),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    if (mounted) setState(() => busy = true);
    repo = ItemRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));
    settings = SettingsRepository();
    await repo.setUp();
    await vendorRepo.setUp();
    await settings.setUp();

    filterVendor = settings.select<int>('items_filter');
    if (items.where((Item i) => i.vendor == filterVendor).isEmpty) {
      filterVendor = null;
    }

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
    if (mounted) setState(() => busy = true);
    items = await repo.select(searchQuery: searchQuery, vendorFilter: filterVendor);

    if (filterVendor == null) {
      for (var item in items) {
        if (filterVendors.where((Vendor v) => v.id == item.vendor).isEmpty) {
          try {
            filterVendors.add(await vendorRepo.selectSingle(item.vendor));
          } catch (e) {
            print(e);
          }
        }
      }
    }

    _sortItems();
    if (mounted) setState(() => busy = false);
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

  void _sortItems() {
    items.sort((Item a, Item b) => a.title.compareTo(b.title));
  }
}
