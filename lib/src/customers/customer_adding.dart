import 'package:flutter/material.dart';

import '../providers/customer_provider.dart';

class CustomerAddingPage extends StatefulWidget {
  @override
  _CustomerAddingPageState createState() => _CustomerAddingPageState();
}

class _CustomerAddingPageState extends State<CustomerAddingPage> {
  final _formKey = GlobalKey<FormState>();

  CustomerProvider db;
  int dropdownValue = 2;

  Customer newCustomer = Customer.empty();

  bool dirty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) =>
                IconButton(icon: Icon(Icons.cancel), onPressed: () => onPopRoute(context))),
        title: Text('Kunden hinzufügen'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: onSaveCustomer,
              tooltip: 'Neuen Kunden abspeichern'),
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
                decoration: InputDecoration(labelText: 'Organisation'),
                onChanged: (String input) {
                  newCustomer.company = input;
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Abteilung'),
                onChanged: (String input) {
                  newCustomer.organizationUnit = input;
                  dirty = true;
                },
              ),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Vorname'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.name = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Nachname'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.surname = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              DropdownButton(
                  hint: Text('Geschlecht'),
                  value: dropdownValue,
                  items: [
                    DropdownMenuItem(value: 0, child: Text('männlich')),
                    DropdownMenuItem(value: 1, child: Text('weiblich')),
                    DropdownMenuItem(value: 2, child: Text('divers')),
                  ],
                  onChanged: (int v) {
                    newCustomer.gender =
                        v == 0 ? Gender.male : v == 1 ? Gender.female : Gender.diverse;
                    setState(() => dropdownValue = v);
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Adresse'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.address = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Postleitzahl'),
                  keyboardType: TextInputType.numberWithOptions(),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.zipCode = int.parse(input);
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Stadt'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.city = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Land'),
                onChanged: (String input) {
                  newCustomer.country = input;
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Telefon'),
                onChanged: (String input) {
                  newCustomer.telephone = input;
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Fax'),
                onChanged: (String input) {
                  newCustomer.fax = input;
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Mobil'),
                onChanged: (String input) {
                  newCustomer.mobile = input;
                  dirty = true;
                },
              ),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.email = input;
                    _formKey.currentState.validate();
                    dirty = true;
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> dbInit() async {
    db = CustomerProvider();
    await db.open('bitter5.db');
  }

  @override
  void initState() {
    super.initState();
    newCustomer.gender = Gender.diverse;
    dbInit();
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
          if (await onSaveCustomer()) {
            Navigator.pop<bool>(context, true);
          } else {
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
      await db.insert(newCustomer);
      return true;
    }
    return false;
  }
}
