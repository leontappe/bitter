import 'package:flutter/material.dart';

import '../../models/crate.dart';
import '../../models/vendor.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../repositories/warehouse_repository.dart';
import '../../widgets/option_dialog.dart';
import '../../widgets/vendor_selector.dart';
import 'crate_list_tile.dart';
import 'warehouse_grid_card.dart';
import 'warehouse_page.dart';

class WarehouseListPage extends StatefulWidget {
  @override
  _WarehouseListPageState createState() => _WarehouseListPageState();
}

class _WarehouseListPageState extends State<WarehouseListPage> {
  WarehouseRepository warehouseRepo;
  ItemRepository itemRepo;
  VendorRepository vendorRepo;
  SettingsRepository settings;

  List<Warehouse> warehouses = [];

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
              tooltip: 'Neuen Lagerplatz erstellen',
              icon: Icon(Icons.add),
              onPressed: () => _onCreateWarehouse(),
            ),
          ],
        ],
      ),
      body: GridView(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 512.0),
        children: <Widget>[
          ...warehouses.map(
            (Warehouse w) => WarehouseGridCard(
              title: w.name,
              onTap: () => Navigator.of(context).push<MaterialPageRoute>(
                MaterialPageRoute(builder: (BuildContext context) => WarehousePage(id: w.id)),
              ),
              children: [
                ...w.inventory.take(5).map<Widget>(
                  (Crate c) {
                    final itemResult = items.where((Item i) => i.id == c.itemId);
                    return CrateListTile(
                      crate: c,
                      item: itemResult.isNotEmpty ? itemResult.single : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
    warehouseRepo = WarehouseRepository(InheritedDatabase.of(context));
    itemRepo = ItemRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));
    settings = SettingsRepository();
    await warehouseRepo.setUp();
    await itemRepo.setUp();
    await vendorRepo.setUp();
    await settings.setUp();

    filterVendor = settings.select<int>('warehouse_filter');

    await onRefresh();
  }

  Future<void> onFilter(int value) async {
    if (value >= 0) {
      filterVendor = value;
    } else {
      filterVendor = null;
    }
    await settings.insert('warehouse_filter', filterVendor);
    await onRefresh();
  }

  Future<void> onRefresh() async {
    warehouses = await warehouseRepo.select(vendorFilter: filterVendor, searchQuery: searchQuery);
    vendors = await vendorRepo.select();
    items = await itemRepo.select(vendorFilter: filterVendor);

    if (mounted) setState(() => busy = false);
  }

  Future<void> onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      searchQuery = value;
    } else {
      searchQuery = null;
    }
    await onRefresh();
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
      await onRefresh();
    }
  }

  Future<void> _onCreateWarehouse() async {
    final dialogResult = await showDialog<Warehouse>(
      context: context,
      builder: (BuildContext context) {
        var result = Warehouse();

        return OptionDialog(
          disableCheckbox: true,
          titleText: 'Lagerplatz erstellen',
          children: [
            VendorSelector(
              initialValue: null,
              onChanged: (Vendor v) => result.vendorId = v.id,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (String input) => result.name = input,
            )
          ],
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Abbrechen'),
            ),
            MaterialButton(
              onPressed: () => Navigator.pop(context, result),
              child: Text('Erstellen'),
            ),
          ],
        );
      },
    );

    if (dialogResult != null) {
      final warehouse = await warehouseRepo.insert(dialogResult);
      setState(() => warehouses.add(warehouse));
    }
  }
}
