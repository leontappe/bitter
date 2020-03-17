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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Abteilung'),
                onChanged: (String input) {
                  newCustomer.organizationUnit = input;
                },
              ),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Vorname'),
                  validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.name = input;
                    _formKey.currentState.validate();
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Nachname'),
                  validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.surname = input;
                    _formKey.currentState.validate();
                  }),
              DropdownButton(
                  hint: Text('Geschlecht'),
                  value: dropdownValue,
                  items: [
                    DropdownMenuItem(value: 0, child: Text('männlich')),
                    DropdownMenuItem(value: 1, child: Text('weiblich')),
                    DropdownMenuItem(value: 2, child: Text('divers')),
                  ],
                  onChanged: (v) {
                    newCustomer.gender =
                        v == 0 ? Gender.male : v == 1 ? Gender.female : Gender.diverse;
                    setState(() => dropdownValue = v);
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Adresse'),
                  validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.address = input;
                    _formKey.currentState.validate();
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Postleitzahl'),
                  keyboardType: TextInputType.numberWithOptions(),
                  validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.zipCode = int.parse(input);
                    _formKey.currentState.validate();
                  }),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Stadt'),
                  validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.city = input;
                    _formKey.currentState.validate();
                  }),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Land'),
                onChanged: (String input) {
                  newCustomer.country = input;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Telefon'),
                onChanged: (String input) {
                  newCustomer.telephone = input;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Fax'),
                onChanged: (String input) {
                  newCustomer.fax = input;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Mobil'),
                onChanged: (String input) {
                  newCustomer.mobile = input;
                },
              ),
              TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                  onChanged: (String input) {
                    newCustomer.email = input;
                    _formKey.currentState.validate();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> dbInit() async {
    db = CustomerProvider();
    db.open('bitter5.db');
  }

  @override
  void initState() {
    super.initState();
    newCustomer.gender = Gender.diverse;
    dbInit();
  }

  void onSaveCustomer() {
    if (_formKey.currentState.validate()) {
      db.insert(newCustomer);
    }
  }
}
