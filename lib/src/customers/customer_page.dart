import 'package:flutter/material.dart';

import '../providers/inherited_provider.dart';
import '../providers/mysql_customer_provider.dart';

class CustomerPage extends StatefulWidget {
  final int id;

  CustomerPage(this.id);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _formKey = GlobalKey<FormState>();

  MySQLCustomerProvider db;
  Customer customer;

  int dropdownValue = 2;

  Customer newCustomer = Customer.empty();

  bool dirty = false;
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    if (customer != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: onPopRoute),
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
            Text(' Aktuelle Informationen', style: Theme.of(context).textTheme.headline4),
            Card(
              margin: EdgeInsets.all(16.0),
              elevation: 8.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (customer.company != null && customer.company.isNotEmpty)
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
                    if (customer.organizationUnit != null && customer.organizationUnit.isNotEmpty)
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
            Text(' Kunde bearbeiten', style: Theme.of(context).textTheme.headline4),
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
                          dirty = true;
                          changed = true;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.organizationUnit,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Abteilung'),
                        onChanged: (String input) {
                          newCustomer.organizationUnit = input;
                          dirty = true;
                          changed = true;
                        },
                      ),
                      TextFormField(
                          initialValue: newCustomer.name,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Vorname'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.name = input;
                            _formKey.currentState.validate();
                            dirty = true;
                            changed = true;
                          }),
                      TextFormField(
                          initialValue: newCustomer.surname,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Nachname'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.surname = input;
                            _formKey.currentState.validate();
                            dirty = true;
                            changed = true;
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
                            changed = true;
                          }),
                      TextFormField(
                          initialValue: newCustomer.address,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Adresse'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.address = input;
                            _formKey.currentState.validate();
                            dirty = true;
                            changed = true;
                          }),
                      TextFormField(
                          initialValue: newCustomer.zipCode.toString(),
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Postleitzahl'),
                          keyboardType: TextInputType.numberWithOptions(),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.zipCode = int.parse(input);
                            _formKey.currentState.validate();
                            dirty = true;
                            changed = true;
                          }),
                      TextFormField(
                          initialValue: newCustomer.city,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Stadt'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.city = input;
                            _formKey.currentState.validate();
                            dirty = true;
                            changed = true;
                          }),
                      TextFormField(
                        initialValue: newCustomer.country,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Land'),
                        onChanged: (String input) {
                          newCustomer.country = input;
                          dirty = true;
                          changed = true;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.telephone,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Telefon'),
                        onChanged: (String input) {
                          newCustomer.telephone = input;
                          dirty = true;
                          changed = true;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.fax,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Fax'),
                        onChanged: (String input) {
                          newCustomer.fax = input;
                          dirty = true;
                          changed = true;
                        },
                      ),
                      TextFormField(
                        initialValue: newCustomer.mobile,
                        maxLines: 1,
                        decoration: InputDecoration(labelText: 'Mobil'),
                        onChanged: (String input) {
                          newCustomer.mobile = input;
                          dirty = true;
                          changed = true;
                        },
                      ),
                      TextFormField(
                          initialValue: newCustomer.email,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'E-Mail'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newCustomer.email = input;
                            _formKey.currentState.validate();
                            dirty = true;
                            changed = true;
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
    //await Future<dynamic>.delayed(Duration(milliseconds: 100));
    db = InheritedProvider.of<Customer>(context).provider as MySQLCustomerProvider;
    //db = MySQLCustomerProvider();
    //await db.open('bitter', host: '127.0.0.1', port: 5432, user: 'ltappe', password: 'stehlen1');
    customer = await db.selectSingle(widget.id);
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
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  void onSaveCustomer() async {
    if (_formKey.currentState.validate()) {
      await db.update(newCustomer);
      dirty = false;
      customer = await db.selectSingle(widget.id);
      setState(() {
        return customer;
      });
    }
  }

  void onDeleteCustomer() async {
    var result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Soll dieser Kunde wirlich gelöscht werden?'),
              actions: <Widget>[
                MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Nein')),
                MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Ja')),
              ],
            ));
    if (result == 1) {
      await db.delete(widget.id);
      Navigator.pop(context, true);
    }
  }

  void onPopRoute() async {
    if (dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Es gibt möglicherweise ungespeicherte Änderungen an diesem Kunden. Vor dem Verlassen abspeichern?'),
                actions: <Widget>[
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, -1), child: Text('Abbrechen')),
                  MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Nein')),
                  MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Ja')),
                ],
              ));
      switch (result) {
        case 0:
          break;
        case 1:
          await onSaveCustomer();
          break;
        default:
          return;
      }
    }

    await Navigator.pop(context, changed);
  }
}
