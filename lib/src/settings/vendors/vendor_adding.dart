import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../providers/inherited_database.dart';
import '../../providers/mysql_provider.dart';
import '../../repositories/vendor_repository.dart';

class VendorAddingPage extends StatefulWidget {
  @override
  _VendorAddingPageState createState() => _VendorAddingPageState();
}

class _VendorAddingPageState extends State<VendorAddingPage> {
  final _formKey = GlobalKey<FormState>();

  VendorRepository repo;
  int dropdownValue = 2;

  Vendor newVendor = Vendor.empty();

  bool dirty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) =>
                IconButton(icon: Icon(Icons.cancel), onPressed: () => onPopRoute(context))),
        title: Text('Verkäufer hinzufügen'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: onSaveCustomer,
              tooltip: 'Neuen Verkäufer abspeichern'),
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
                decoration: InputDecoration(labelText: 'Name'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  newVendor.name = input;
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  newVendor.address = input;
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Stadt'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.city = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'IBAN'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.iban = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'BIC'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.bic = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Bank'),
                  keyboardType: TextInputType.numberWithOptions(),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.bank = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Steuernummer'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.taxNr = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Umsatzsteuernummer'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.vatNr = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Website'),
                  onChanged: (String input) {
                    newVendor.website = input;
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Adresszeile für Briefkopf'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.fullAddress = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Prefix für Rechnungsnummern'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newVendor.billPrefix = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
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
    repo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    //db = MySQLCustomerProvider();
    //await db.open('bitter', host: '127.0.0.1', port: 5432, user: 'ltappe', password: 'stehlen1');
  }

  void onPopRoute(BuildContext context) async {
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
          if (!await onSaveCustomer()) {
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

  Future<bool> onSaveCustomer() async {
    if (_formKey.currentState.validate()) {
      await repo.insert(newVendor);
      Navigator.pop<bool>(context, true);
      return true;
    }
    return false;
  }
}
