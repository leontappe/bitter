import 'package:flutter/material.dart';

import '../../models/crate.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/commissioning_repository.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../repositories/warehouse_repository.dart';

class CommissioningCreatorPage extends StatefulWidget {
  final Warehouse warehouse;

  const CommissioningCreatorPage({super.key, required this.warehouse});

  @override
  _CommissioningCreatorPageState createState() => _CommissioningCreatorPageState();
}

class _CommissioningCreatorPageState extends State<CommissioningCreatorPage> {
  late CommissioningRepository commissioningRepo;
  late ItemRepository itemRepo;
  late VendorRepository vendorRepo;
  late WarehouseRepository warehouseRepo;

  late Warehouse warehouse = widget.warehouse;
  Vendor? vendor;
  List<Item> items = [];

  bool busy = false;

  late Commissioning newComm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kommissionierung erstellen'),
        actions: [
          IconButton(icon: Icon(Icons.save_alt), onPressed: _onSaveAndExit),
        ],
      ),
      body: ListView(
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text('Infos', style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListTile(title: Text('Verkäufer: '), trailing: Text(vendor?.name ?? '')),
                ListTile(title: Text('Lagerplatz: '), trailing: Text(warehouse.name ?? '')),
              ],
            ),
          ),
          ...(warehouse?.inventory ?? []).map<Widget>((Crate c) {
            final itemResult = items.where((Item i) => i.id == c.itemId);
            return ListTile(
              title: Text(c.name ??
                  (itemResult.isNotEmpty ? 'Kiste mit ${itemResult.single.title}' : 'Kiste')),
              subtitle: Text(itemResult.isNotEmpty
                  ? itemResult.single.title + ' - ' + (itemResult.single.description ?? '')
                  : ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _onEmptyCrate(c),
                    icon: Icon(Icons.remove),
                  ),
                  Text(
                    '${c.level}',
                    style: TextStyle(
                        color: c.level >
                                widget.warehouse.inventory
                                    .singleWhere((Crate crate) => crate.uid == c.uid)
                                    .level
                            ? Colors.green
                            : c.level <
                                    widget.warehouse.inventory
                                        .singleWhere((Crate crate) => crate.uid == c.uid)
                                        .level
                                ? Colors.red
                                : Colors.black),
                  ),
                  IconButton(
                    onPressed: () => _onFillCrate(c),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            );
          }),
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
    commissioningRepo = CommissioningRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));
    itemRepo = ItemRepository(InheritedDatabase.of(context));
    warehouseRepo = WarehouseRepository(InheritedDatabase.of(context));
    await vendorRepo.setUp();
    await commissioningRepo.setUp();
    await itemRepo.setUp();
    await warehouseRepo.setUp();

    vendor = await vendorRepo.selectSingle(warehouse.vendorId!);

    items = await itemRepo.select(vendorFilter: warehouse.vendorId);

    if (mounted) setState(() => busy = false);
  }

  @override
  void initState() {
    warehouse = Warehouse.fromMap(widget.warehouse.toMap);
    newComm = Commissioning(vendorId: warehouse.vendorId, warehouseId: warehouse.id);
    super.initState();
  }

  List<Item> inventoryDiff(List<Crate> old, List<Crate> fresh) {
    var diffItems = <Item>[];
    for (var crate in old) {
      final itemResult = items.where((Item i) => i.id == crate.itemId);
      if (diffItems.where((Item i) => i.id == crate.itemId).isEmpty) {
        final newItem = itemResult.single;
        newItem.quantity = crate.level - fresh.singleWhere((Crate c) => c.uid == crate.uid).level;
        diffItems.add(newItem);
      } else {
        diffItems.singleWhere((Item i) => i.id == crate.itemId).quantity +=
            crate.level - fresh.singleWhere((Crate c) => c.uid == crate.uid).level;
      }
    }
    diffItems.removeWhere((Item i) => i.quantity == 0);
    return diffItems;
  }

  void _onEmptyCrate(Crate crate) {
    if (crate.level > 0) {
      setState(() => warehouse.inventory.singleWhere((Crate c) => c.uid == crate.uid).level--);
    }
  }

  void _onFillCrate(Crate crate) {
    if (crate.size == 0 || crate.level < crate.size) {
      setState(() => warehouse.inventory.singleWhere((Crate c) => c.uid == crate.uid).level++);
    }
  }

  Future<void> _onSaveAndExit() async {
    newComm.timestamp = DateTime.now();
    newComm.items = inventoryDiff(widget.warehouse.inventory, warehouse.inventory);

    print(newComm);

    await warehouseRepo.update(warehouse);

    await commissioningRepo.insert(newComm);
  }
}
