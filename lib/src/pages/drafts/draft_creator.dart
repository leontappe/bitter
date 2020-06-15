import 'dart:async';

import 'package:bitter/src/repositories/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/draft.dart';
import '../../models/item.dart';
import '../../models/vendor.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../widgets/vendor_selector.dart';
import 'draft_popup_menu.dart';
import 'item_editor_tile.dart';
import 'items_bloc.dart';

class DraftCreatorPage extends StatefulWidget {
  final Draft draft;

  const DraftCreatorPage({Key key, this.draft}) : super(key: key);

  @override
  _DraftCreatorPageState createState() => _DraftCreatorPageState();
}

class _DraftCreatorPageState extends State<DraftCreatorPage> {
  final _formKey = GlobalKey<FormState>();

  DraftRepository repo;
  CustomerRepository customerRepo;
  SettingsRepository settingsRepo;
  ItemRepository itemRepo;
  VendorRepository vendorRepo;

  ItemsBloc itemsBloc;

  String editor;

  Draft draft;
  bool dirty;
  bool changed;

  bool customerIsset = false;
  bool vendorIsset = false;
  List<Customer> _customers;
  Vendor _vendor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) => IconButton(
                  tooltip: 'Zurück',
                  icon: Icon((widget.draft != null) ? Icons.arrow_back_ios : Icons.cancel),
                  onPressed: () => onPopRoute(context),
                )),
        title: Text(
            (widget.draft != null) ? 'Entwurf ${widget.draft.id}' : 'Rechnungsentwurf hinzufügen'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: onSaveDraft,
            tooltip: 'Rechnungsentwurf abspeichern',
          ),
          if (widget.draft != null)
            DraftPopupMenu(
              id: draft.id,
              onCompleted: (bool changed) =>
                  changed ? Navigator.popAndPushNamed(context, '/bills', result: true) : null,
            )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('Kunde', style: Theme.of(context).textTheme.headline6),
                trailing: (customerIsset ?? true) ? null : Icon(Icons.error, color: Colors.red),
                subtitle: DropdownButton<int>(
                  hint: Text('Kunden auswählen'),
                  isExpanded: true,
                  value: draft.customer,
                  onChanged: (int value) {
                    setState(() {
                      draft.customer = value;
                    });
                    dirty = true;
                    validateDropdowns();
                  },
                  items: <DropdownMenuItem<int>>[
                    ..._customers
                        .map<DropdownMenuItem<int>>((Customer c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text((c.company != null && c.company.isNotEmpty)
                                ? '${c.company} - ${c.name} ${c.surname}'
                                : '${c.name} ${c.surname}')))
                        .toList()
                  ],
                ),
              ),
              ListTile(
                title: Text('Verkäufer', style: Theme.of(context).textTheme.headline6),
                trailing: (vendorIsset ?? true) ? null : Icon(Icons.error, color: Colors.red),
                subtitle: VendorSelector(
                  initialValue: draft?.vendor,
                  onChanged: (Vendor v) {
                    draft.vendor = v.id;
                    _vendor = v;
                    draft.tax = _vendor.defaultTax;
                    draft.dueDays = _vendor.defaultDueDays;
                    dirty = true;
                    validateDropdowns();
                  },
                ),
              ),
              ListTile(
                title: Text('Lieferdatum/Leistungsdatum:',
                    style: Theme.of(context).textTheme.headline6),
                trailing: Container(
                  width: 196.0,
                  height: 64.0,
                  child: MaterialButton(
                    child: Text((draft.serviceDate != null)
                        ? draft.serviceDate.toString().split(' ').first
                        : 'Am Rechnungsdatum'),
                    onPressed: (vendorIsset)
                        ? () async {
                            draft.serviceDate = await showDatePicker(
                              context: context,
                              initialDate: draft.serviceDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 20),
                              cancelText: 'Löschen',
                              confirmText: 'Übernehmen',
                            );
                            setState(() => draft);
                            dirty = true;
                          }
                        : null,
                  ),
                ),
              ),
              ListTile(
                title: Text('Zahlungsziel:', style: Theme.of(context).textTheme.headline6),
                trailing: Container(
                  width: 80.0,
                  height: 64.0,
                  child: TextFormField(
                    enabled: vendorIsset,
                    controller: TextEditingController(text: draft.dueDays?.toString() ?? '14'),
                    maxLines: 1,
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(hintText: '14', suffixText: 'Tage'),
                    validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                    onChanged: (String input) {
                      setState(() => draft.dueDays = int.parse(input));
                      _formKey.currentState.validate();
                      dirty = true;
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(_vendor?.userMessageLabel ?? 'Benutzerdefinierter Rechnungskommentar:',
                    style: Theme.of(context).textTheme.headline6),
                trailing: Container(
                  width: 196.0,
                  child: TextFormField(
                    initialValue: draft.userMessage,
                    onChanged: (String input) {
                      setState(() => draft.userMessage = input);
                      dirty = true;
                    },
                  ),
                ),
              ),
              Text('Artikel', style: Theme.of(context).textTheme.headline6),
              BlocBuilder<ItemsBloc, ItemsState>(
                bloc: itemsBloc,
                builder: (BuildContext context, ItemsState state) {
                  if (state.items != null) {
                    return Column(children: <Widget>[
                      ...state.items.map<ItemEditorTile>((Item e) => ItemEditorTile(
                            item: e,
                            defaultTax: draft.tax,
                            itemChanged: onUpdateItem,
                            itemDeleted: (Item e) => onRemoveItem(e.uid),
                            itemSaved: onSaveItem,
                          )),
                    ]);
                  }
                  return Container(width: 0.0, height: 0.0);
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                child: RaisedButton(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.add, size: 32.0),
                  onPressed: (vendorIsset)
                      ? () => onAddItem(Item(price: null, title: '', tax: _vendor.defaultTax ?? 19))
                      : null,
                ),
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
    repo = DraftRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    itemRepo = ItemRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    settingsRepo = SettingsRepository();

    await itemRepo.setUp();
    await settingsRepo.setUp();
    await vendorRepo.setUp();

    editor = await settingsRepo.getUsername();
    _customers = await customerRepo.select();
    if (vendorIsset) {
      _vendor = await vendorRepo.selectSingle(draft.vendor);
    }

    setState(() => _customers);
  }

  @override
  void initState() {
    itemsBloc = ItemsBloc();

    if (widget.draft != null) {
      draft = widget.draft;
      itemsBloc.onBulkAdd(draft.items);
      vendorIsset = draft.vendor != null;
      customerIsset = draft.customer != null;
    } else {
      draft = Draft.empty();
    }

    _customers = [];
    dirty = false;
    changed = false;

    super.initState();
  }

  void onAddItem(Item item) {
    itemsBloc.onAddItem(item);
    dirty = true;
  }

  Future<void> onPopRoute(BuildContext context) async {
    if (dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Wenn du ohne Speichern fortfährst gehen alle hier eingebenen Daten verloren. Vor dem Verlassen abspeichern?'),
                actions: <Widget>[
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, -1), child: Text('Abbrechen')),
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, 0), child: Text('Verwerfen')),
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, 1), child: Text('Speichern')),
                ],
              ));
      switch (result) {
        case 0:
          Navigator.pop<bool>(context, false);
          break;
        case 1:
          if (!await onSaveDraft()) {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Es gibt noch Fehler und/oder fehlende Felder in dem Formular, sodass gerade nicht gespeichert werden kann.'),
              duration: Duration(seconds: 3),
            ));
          } else {
            Navigator.pop(context, true);
          }
          break;
        default:
          return;
      }
    } else {
      Navigator.pop<bool>(context, changed);
    }
  }

  void onRemoveItem(String id) {
    itemsBloc.onRemoveItem(id);
    dirty = true;
  }

  Future<bool> onSaveDraft() async {
    if (_formKey.currentState.validate() && validateDropdowns()) {
      draft.items = itemsBloc.items;

      for (var i = 0; i < draft.items.length; i++) {
        if (draft.items[i].tax == null) {
          draft.items[i].tax = draft.tax;
        }
      }

      draft.editor = editor;

      if (widget.draft != null) {
        await repo.update(draft);
      } else {
        await repo.insert(draft);
      }

      dirty = false;
      if (widget.draft == null) {
        Navigator.pop<bool>(context, true);
      }
      changed = true;
      return true;
    }
    return false;
  }

  Future<void> onSaveItem(Item item) async {
    item.quantity = 1;
    await itemRepo.insert(item);
  }

  void onUpdateItem(Item item) {
    itemsBloc.onUpdateItem(item);
    dirty = true;
  }

  bool validateDropdowns() {
    setState(() {
      vendorIsset = draft.vendor != null;
      customerIsset = draft.customer != null;
    });

    return vendorIsset && customerIsset;
  }
}
