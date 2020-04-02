import 'package:bitter/src/models/item.dart';
import 'package:bitter/src/models/vendor.dart';
import 'package:bitter/src/repositories/vendor_repository.dart';

import '../repositories/customer_repository.dart';
import 'package:flutter/material.dart';

import '../models/draft.dart';
import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/draft_repository.dart';

class DraftCreatorPage extends StatefulWidget {
  @override
  _DraftCreatorPageState createState() => _DraftCreatorPageState();
}

class _DraftCreatorPageState extends State<DraftCreatorPage> {
  final _formKey = GlobalKey<FormState>();

  DraftRepository repo;
  CustomerRepository customerRepo;
  VendorRepository vendorRepo;

  Draft draft = Draft.empty();

  bool dirty = false;

  List<Customer> _customers = [];
  List<Vendor> _vendors = [];

  Item newItem;
  List<Item> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) =>
                IconButton(icon: Icon(Icons.cancel), onPressed: () => onPopRoute(context))),
        title: Text('Rechnungsentwurf hinzufügen'),
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
            itemExtent: 64.0,
            children: <Widget>[
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Rechnungsnummer'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  draft.billNr = input;
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Bearbeiter*in'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  draft.editor = input;
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                title: Text('Kunde'),
                subtitle: DropdownButton<int>(
                  hint: Text('Kunden auswählen'),
                  isExpanded: true,
                  value: draft.customer,
                  onChanged: (int value) {
                    setState(() {
                      draft.customer = value;
                    });
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
                contentPadding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                title: Text('Verkäufer'),
                subtitle: DropdownButton<int>(
                  hint: Text('Verkäufer auswählen'),
                  isExpanded: true,
                  value: draft.vendor,
                  onChanged: (int value) {
                    setState(() {
                      draft.vendor = value;
                    });
                  },
                  items: <DropdownMenuItem<int>>[
                    ..._vendors
                        .map<DropdownMenuItem<int>>((Vendor v) =>
                            DropdownMenuItem<int>(value: v.id, child: Text('${v.name}')))
                        .toList()
                  ],
                ),
              ),
              Divider(),
              Text('Artikel', style: Theme.of(context).textTheme.headline6),
              if (_items.isEmpty) ListTile(title: Text('Keine Artikel vorhanden')),
              ..._items
                  .map((Item i) => ListTile(
                      title: Text(i.title), subtitle: Text('Steuer: ${i.tax.toString()}%')))
                  .toList(),
              TextFormField(
                initialValue: newItem?.title ?? '',
                maxLines: 1,
                decoration: InputDecoration(
                    labelText: 'Artikelname',
                    suffix: IconButton(icon: Icon(Icons.add), onPressed: onAddItem)),
                onChanged: (String input) {
                  newItem.title = input;
                },
              ),
              Divider(),
              TextFormField(
                initialValue: '19',
                maxLines: 1,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(labelText: 'Standard-Steuersatz', suffix: Text('%')),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  draft.tax = int.parse(input);
                  _formKey.currentState.validate();
                  dirty = true;
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
    repo = DraftRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);

    _customers = await customerRepo.select();
    _vendors = await vendorRepo.select();
    newItem = Item.empty();
    draft.tax = 19;

    setState(() => _customers);
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
    if (_formKey.currentState.validate()) {
      await repo.insert(draft);
      Navigator.pop<bool>(context, true);
      return true;
    }
    return false;
  }

  void onAddItem() {
    if (newItem.tax == 0) {
      newItem.tax = draft.tax;
    }
    setState(() {
      _items.add(newItem);
      newItem = Item.empty();
    });
    draft.items = _items;
  }
}
