import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/crate.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/warehouse_repository.dart';
import '../../widgets/item_selector.dart';
import '../../widgets/option_dialog.dart';

class WarehousePage extends StatefulWidget {
  final int id;

  const WarehousePage({this.id});

  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  WarehouseRepository warehouseRepo;
  ItemRepository itemRepo;

  Warehouse warehouse;

  List<Item> items = [];

  bool busy = false;

  Uuid uuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(warehouse?.name ?? ''),
        actions: [
          IconButton(
            tooltip: 'Neue Kiste erstellen',
            icon: Icon(Icons.add_box_rounded),
            onPressed: () => _onCreateCrate(),
          ),
        ],
      ),
      body: busy
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ...warehouse.inventory.map<Widget>(
                  (Crate c) {
                    final filteredItems = items.where((Item i) => i.id == c.itemId);
                    return ListTile(
                      title: Text(c.name ??
                          (filteredItems.isNotEmpty
                              ? 'Kiste mit ${filteredItems.single.title}'
                              : 'Kiste')),
                      subtitle: Text(filteredItems.isNotEmpty
                          ? filteredItems.single.title + ' - ' + filteredItems.single.description
                          : ''),
                      trailing: Text('${c.level}/${c.size == 0 ? 'Unbegrenzt' : c.size}'),
                      onLongPress: () => _onDeleteCrate(c.uid),
                    );
                  },
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
    await warehouseRepo.setUp();
    await itemRepo.setUp();

    await onRefresh();
  }

  @override
  void initState() {
    uuid = Uuid();
    super.initState();
  }

  Future<void> onRefresh() async {
    warehouse = await warehouseRepo.selectSingle(widget.id);
    items = await itemRepo.select(vendorFilter: warehouse.vendorId);
    if (mounted) setState(() => busy = false);
  }

  Future<void> _onCreateCrate() async {
    final dialogResult = await showDialog<Crate>(
        context: context,
        builder: (BuildContext context) {
          var isMetaCrate = false;
          var result = Crate(uuid.v4());
          var sizeController =
              TextEditingController(text: result.size > 0 ? result.size.toString() : 'Unbegrenzt');
          return OptionDialog(
            titleText: 'Neue Kiste',
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (String input) => result.name = input,
              ),
              TextField(
                  controller: sizeController,
                  onTap: () => sizeController.clear(),
                  onEditingComplete: () {
                    if (result.size == 0) {
                      sizeController.text = 'Unbegrenzt';
                    }
                  },
                  decoration: InputDecoration(labelText: 'Kapazität', suffixText: 'Einheiten'),
                  onChanged: (String input) {
                    if (input != null && input.isNotEmpty) {
                      result.size = int.parse(input);
                    }
                  }),
              TextField(
                controller: TextEditingController(text: result.level.toString()),
                decoration: InputDecoration(labelText: 'Füllstand', suffixText: 'Einheiten'),
                onChanged: (String input) {
                  if (input != null && input.isNotEmpty) {
                    result.level = int.parse(input);
                  }
                },
              ),
              ItemSelector(
                onChanged: (Item i) {
                  result.itemId = i.id;
                  print(result.toMap);
                },
                initialValue: result.itemId,
                disabled: result.subcrate != null,
              ),
            ],
            actions: [
              MaterialButton(
                child: Text('Abbrechen'),
                onPressed: () => Navigator.pop(context, null),
              ),
              MaterialButton(
                child: Text('Erstellen'),
                onPressed: () => Navigator.pop(context, result),
              ),
            ],
            checkboxText: 'Enthält Kisten statt Artikel',
            onChecked: (bool input) {
              setState(() {
                if (input) {
                  result.itemId = null;
                  result.subcrate = Crate(uuid.v4());
                } else {
                  result.subcrate = null;
                }
                isMetaCrate = input;
                print(result.toMap);
              });
            },
            checked: isMetaCrate,
          );
        });

    if (dialogResult == null) return;

    setState(() => warehouse.inventory.add(dialogResult));

    await warehouseRepo.update(warehouse);
  }

  Future<void> _onDeleteCrate(String uid) async {
    setState(() => warehouse.inventory.removeWhere((Crate c) => c.uid == uid));
    await warehouseRepo.update(warehouse);
  }
}
