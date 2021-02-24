import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';

class WarehousePage extends StatefulWidget {
  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  ItemRepository itemRepo;
  VendorRepository vendorRepo;
  SettingsRepository settings;

  List<Vendor> vendors = [];
  int filterVendor;

  bool searchEnabled = false;
  String searchQuery;

  bool busy;

  List<Item> items;

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
            : Text('Warenverwaltung'),
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
              tooltip: 'Neue Buchung erstellen',
              icon: Icon(Icons.add),
              onPressed: null,
            ),
          ],
        ],
      ),
      body: ListView(
        children: <Widget>[],
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
    itemRepo = ItemRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));
    settings = SettingsRepository();
    await itemRepo.setUp();
    await vendorRepo.setUp();
    await settings.setUp();

    filterVendor = settings.select<int>('warehouse_filter');

    vendors = await vendorRepo.select();
    items = await itemRepo.select();
    if (filterVendor != null) {
      items = items.where((Item i) => i.vendor == filterVendor).toList();
    }

    if (mounted) setState(() => busy = false);
  }

  Future<void> onFilter(int value) async {
    if (value >= 0) {
      filterVendor = value;
    } else {
      filterVendor = null;
    }
    await settings.insert('warehouse_filter', filterVendor);
    setState(() => true);
  }

  Future<void> onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      searchQuery = value;
    } else {
      searchQuery = null;
    }
    //await onGetItems();
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
      //await onGetItems();
    }
  }
}
