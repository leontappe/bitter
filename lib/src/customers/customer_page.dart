import 'package:flutter/material.dart';

import '../providers/customer_provider.dart';

class CustomerPage extends StatefulWidget {
  final int id;

  CustomerPage(this.id);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _formKey = GlobalKey<FormState>();

  CustomerProvider db;
  Customer customer;

  int dropdownValue = 2;

  Customer newCustomer = Customer.empty();

  @override
  Widget build(BuildContext context) {
    if (customer != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Kundenansicht'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDeleteCustomer,
            ),
            IconButton(icon: Icon(Icons.save), onPressed: onSaveCustomer),
          ],
        ),
        body: ListView(
          semanticChildCount: 4,
          children: <Widget>[
            Text('Aktuelle Informationen', style: Theme.of(context).textTheme.headline4),
            Card(
              margin: EdgeInsets.all(16.0),
              elevation: 8.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (customer.company != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(customer.company, style: Theme.of(context).textTheme.headline5),
                          Text('Ansprechpartner: ' + customer.name + ' ' + customer.surname)
                        ],
                      )
                    else
                      Text(customer.name + ' ' + customer.surname,
                          style: Theme.of(context).textTheme.headline5),
                    if (customer.organizationUnit != null)
                      Text('Abteilung: ${customer.organizationUnit}'),
                    Text('Adresse: ${customer.address}'),
                    Text('Stadt: ${customer.zipCode} ${customer.city}'),
                    if (customer.country != null) Text('Land: ${customer.country}'),
                    if (customer.telephone != null) Text('Telefon: ${customer.telephone}'),
                    if (customer.fax != null) Text('Fax: ${customer.fax}'),
                    if (customer.mobile != null) Text('Mobil: ${customer.mobile}'),
                    Text('E-Mail: ${customer.email}')
                  ],
                ),
              ),
            ),
            Text('Kunde bearbeiten', style: Theme.of(context).textTheme.headline4),
            if (newCustomer.name != null)
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        initialValue: newCustomer.company,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Organisation'),
                        onChanged: (String input) {
                          newCustomer.company = input;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.organizationUnit,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Abteilung'),
                        onChanged: (String input) {
                          newCustomer.organizationUnit = input;
                        },
                      ),
                      TextFormField(
                          initialValue: newCustomer.name,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Vorname'),
                          validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.name = input;
                            _formKey.currentState.validate();
                          }),
                      TextFormField(
                          initialValue: newCustomer.surname,
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
                          initialValue: newCustomer.address,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Adresse'),
                          validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.address = input;
                            _formKey.currentState.validate();
                          }),
                      TextFormField(
                          initialValue: newCustomer.zipCode.toString(),
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Postleitzahl'),
                          keyboardType: TextInputType.numberWithOptions(),
                          validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.zipCode = int.parse(input);
                            _formKey.currentState.validate();
                          }),
                      TextFormField(
                          initialValue: newCustomer.city,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Stadt'),
                          validator: (input) => input.length < 1 ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.city = input;
                            _formKey.currentState.validate();
                          }),
                      TextFormField(
                        initialValue: newCustomer.country,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Land'),
                        onChanged: (String input) {
                          newCustomer.country = input;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.telephone,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Telefon'),
                        onChanged: (String input) {
                          newCustomer.telephone = input;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.fax,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Fax'),
                        onChanged: (String input) {
                          newCustomer.fax = input;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.mobile,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Mobil'),
                        onChanged: (String input) {
                          newCustomer.mobile = input;
                        },
                      ),
                      TextFormField(
                          initialValue: newCustomer.email,
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
          ],
        ),
      );
    }
    return Container(width: 0.0, height: 0.0);
  }

  void initDb() async {
    db = CustomerProvider();
    await db.open('bitter5.db');
    customer = await db.getCustomer(widget.id);
    if (customer == null) {
      Navigator.pop(context);
      return null;
    }
    setState(() {
      newCustomer = customer;
      dropdownValue = customer.gender.index;
      return customer;
    });
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

  void onSaveCustomer() async {
    if (_formKey.currentState.validate()) {
      db.update(newCustomer);
      customer = await db.getCustomer(widget.id);
      setState(() {
        return customer;
      });
    }
  }

  void onDeleteCustomer() async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Soll dieser Kunde wirlich gelöscht werden?'),
              actions: <Widget>[
                MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Nein')),
                MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Ja')),
              ],
            ));
    if (result == 1) {
      db.delete(widget.id);
      Navigator.pop(context);
    }
  }
}
