import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/draft.dart';
import '../models/item.dart';
import '../models/vendor.dart';
import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/draft_repository.dart';
import '../repositories/vendor_repository.dart';
import 'item_creator_tile.dart';
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
  VendorRepository vendorRepo;

  ItemsBloc itemsBloc;

  Draft draft;
  bool dirty;

  bool customerIsset;
  bool vendorIsset;
  List<Customer> _customers;
  List<Vendor> _vendors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) => IconButton(
                icon: Icon((widget.draft != null) ? Icons.arrow_back_ios : Icons.cancel),
                onPressed: () => onPopRoute(context))),
        title: Text(
            (widget.draft != null) ? 'Entwurf ${widget.draft.id}' : 'Rechnungsentwurf hinzufügen'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: onSaveDraft,
              tooltip: 'Neuen Rechnungsentwurf abspeichern'),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('Bearbeiter*in', style: Theme.of(context).textTheme.headline6),
                subtitle: TextFormField(
                  controller: TextEditingController(text: draft.editor ?? ''),
                  maxLines: 1,
                  decoration: InputDecoration(hintText: 'Erika Musterfrau'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    draft.editor = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  },
                ),
              ),
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
                subtitle: DropdownButton<int>(
                  hint: Text('Verkäufer auswählen'),
                  isExpanded: true,
                  value: draft.vendor,
                  onChanged: (int value) {
                    setState(() {
                      draft.vendor = value;
                    });
                    dirty = true;
                    validateDropdowns();
                  },
                  items: <DropdownMenuItem<int>>[
                    ..._vendors
                        .map<DropdownMenuItem<int>>((Vendor v) =>
                            DropdownMenuItem<int>(value: v.id, child: Text('${v.name}')))
                        .toList()
                  ],
                ),
              ),
              ListTile(
                title: Text('Standard-Steuersatz', style: Theme.of(context).textTheme.headline6),
                trailing: Container(
                  width: 80.0,
                  height: 64.0,
                  child: TextFormField(
                    initialValue: '19',
                    maxLines: 1,
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(hintText: '19', suffixText: '%'),
                    validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                    onChanged: (String input) {
                      draft.tax = int.parse(input);
                      _formKey.currentState.validate();
                      dirty = true;
                    },
                  ),
                ),
              ),
              Text('Artikel', style: Theme.of(context).textTheme.headline6),
              BlocBuilder<ItemsBloc, ItemsState>(
                bloc: itemsBloc,
                builder: (BuildContext context, ItemsState state) => Column(
                  children: <Widget>[
                    if (state.items.isEmpty)
                      ListTile(title: Text('Es wurden noch keine Artikel hinzugefügt')),
                    ...state.items.map<ItemEditorTile>((Item e) => ItemEditorTile(
                          item: e,
                          defaultTax: draft.tax,
                          itemChanged: (Item e) => itemsBloc.onUpdateItem(e),
                          itemDeleted: (Item e) => itemsBloc.onRemoveItem(e.id),
                        )),
                  ],
                ),
              ),
              Divider(),
              ItemCreatorTile(defaultTax: draft.tax, itemAdded: onAddItem),
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
    repo = DraftRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);

    _customers = await customerRepo.select();
    _vendors = await vendorRepo.select();

    setState(() => _customers);
  }

  @override
  void initState() {
    itemsBloc = ItemsBloc();

    if (widget.draft != null) {
      draft = widget.draft;
      itemsBloc.onBulkAdd(draft.items);
    } else {
      draft = Draft.empty();
      draft.tax = 19;
    }

    _customers = [];
    _vendors = [];
    dirty = false;

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
                  MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Nein')),
                  MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Ja')),
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
          }
          break;
        default:
          return;
      }
    } else {
      Navigator.pop<bool>(context, false);
    }
  }

  Future<bool> onSaveDraft() async {
    if (_formKey.currentState.validate() && validateDropdowns()) {
      draft.items = itemsBloc.items;

      if (widget.draft != null) {
        await repo.update(draft);
      } else {
        await repo.insert(draft);
      }

      dirty = false;
      Navigator.pop<bool>(context, true);
      return true;
    }
    return false;
  }

  bool validateDropdowns() {
    setState(() {
      vendorIsset = draft.vendor != null;
      customerIsset = draft.customer != null;
    });

    return vendorIsset && customerIsset;
  }
}
