import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/crate.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/commissioning_repository.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/warehouse_repository.dart';
import '../../util/format_util.dart';
import '../../widgets/info_cards/items_card.dart';
import '../../widgets/item_selector.dart';
import '../../widgets/option_dialog.dart';
import 'commissioning_creator.dart';
import 'crate_list_tile.dart';

enum CratePopupSelection { delete }

class WarehousePage extends StatefulWidget {
  final int id;

  const WarehousePage({this.id});

  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  WarehouseRepository warehouseRepo;
  CommissioningRepository commissioningRepository;
  ItemRepository itemRepo;

  Warehouse warehouse;

  List<Commissioning> commissionings = [];

  List<Item> items = [];

  bool busy = false;

  Uuid uuid;

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(warehouse?.name ?? ''),
          actions: [
            if (currentIndex == 0)
              IconButton(
                tooltip: 'Neue Kiste erstellen',
                icon: Icon(Icons.add_box_rounded),
                onPressed: () => _onCreateCrate(),
              ),
            if (currentIndex == 1)
              IconButton(
                tooltip: 'Neue Kommissionierung erstellen',
                icon: Icon(Icons.note_add_rounded),
                onPressed: () => _onCreateCommissioning(),
              ),
          ],
          bottom: TabBar(
            onTap: (int index) => setState(() => currentIndex = index),
            tabs: [
              Tab(icon: Icon(Icons.storage_rounded)),
              Tab(icon: Icon(Icons.fact_check_outlined)),
            ],
          ),
        ),
        body: busy
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () => onRefresh(),
                    child: ListView(
                      children: [
                        ...warehouse.inventory.map<Widget>(
                          (Crate c) {
                            final filteredItems = items.where((Item i) => i.id == c.itemId);
                            return CrateListTile(
                              crate: c,
                              item: filteredItems.isNotEmpty ? filteredItems.single : null,
                              onLongPress: () => _onDeleteCrate(c.uid),
                              trailing: PopupMenuButton(
                                tooltip: 'Menü zeigen',
                                onSelected: (CratePopupSelection input) => onSelected(input, c),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<CratePopupSelection>>[
                                  const PopupMenuItem<CratePopupSelection>(
                                    value: CratePopupSelection.delete,
                                    child: Text('Kiste löschen'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () => onRefresh(),
                    child: ListView(
                      children: [
                        ...commissionings.reversed.map<Widget>((Commissioning c) => ListTile(
                              title: Text('Kommissionierung vom ${formatDateTime(c.timestamp)}'),
                              subtitle: Text('${c.items.length} Artikel'),
                              onTap: () => _showCommissioningDetails(c),
                            )),
                      ],
                    ),
                  ),
                ],
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
    warehouseRepo = WarehouseRepository(InheritedDatabase.of(context));
    commissioningRepository = CommissioningRepository(InheritedDatabase.of(context));
    itemRepo = ItemRepository(InheritedDatabase.of(context));
    await warehouseRepo.setUp();
    await commissioningRepository.setUp();
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
    commissionings = await commissioningRepository.select(warehouesFilter: widget.id);
    if (mounted) setState(() => busy = false);
  }

  void onSelected(CratePopupSelection value, Crate crate) {
    switch (value) {
      case CratePopupSelection.delete:
        if (crate.level == 0) {
          _onDeleteCrate(crate.uid);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Nur leere Kisten können gelöscht werden'),
            duration: Duration(seconds: 3),
          ));
        }
        break;
      default:
    }
  }

  void _onCreateCommissioning() {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => CommissioningCreatorPage(warehouse: warehouse)));
  }

  Future<void> _onCreateCrate() async {
    final dialogResult = await showDialog<Crate>(
        context: context,
        builder: (BuildContext context) {
          var result = Crate(uuid.v4());
          var sizeController =
              TextEditingController(text: result.size > 0 ? result.size.toString() : 'Unbegrenzt');
          return OptionDialog(
            disableCheckbox: true,
            titleText: 'Neue Kiste',
            actions: [
              MaterialButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Abbrechen'),
              ),
              MaterialButton(
                onPressed: () {
                  if (result.itemId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Bitte gebe der Kiste einen Artikel '),
                      duration: Duration(seconds: 3),
                    ));
                  } else {
                    Navigator.pop(context, result);
                  }
                },
                child: Text('Erstellen'),
              ),
            ],
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

  Future<void> _showCommissioningDetails(Commissioning comm) async {
    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
              title: Text('Kommissionierung vom ${formatDateTime(comm.timestamp)}'),
              children: [
                ListTile(title: Text('ID:'), trailing: Text('${comm.id}')),
                ListTile(
                    title: Text('Zeitstempel:'),
                    trailing: Text('${comm.timestamp.toIso8601String()}')),
                ListTile(title: Text('Verkäufer:'), trailing: Text('')),
                ListTile(title: Text('Lagerplatz:'), trailing: Text('${warehouse?.name ?? ''}')),
                ItemsCard(items: comm.items, sum: comm.sum),
              ],
            ));
  }
}
