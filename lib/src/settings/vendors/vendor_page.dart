import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/vendor.dart';
import '../../providers/inherited_database.dart';
import '../../providers/mysql_provider.dart';
import '../../repositories/vendor_repository.dart';

class VendorPage extends StatefulWidget {
  final int id;

  VendorPage(this.id);

  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  final _formKey = GlobalKey<FormState>();

  VendorRepository repo;
  Vendor vendor;

  Vendor newVendor = Vendor.empty();

  bool dirty = false;
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    if (vendor != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: onPopRoute),
          title: Text('Verkäuferansicht'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDeleteVendor,
            ),
            IconButton(icon: Icon(Icons.save), onPressed: onSaveVendor),
          ],
        ),
        body: ListView(
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
                    Text(vendor.name, style: Theme.of(context).textTheme.headline5),
                    Text('Adresse: ${vendor.address}'),
                    Text('Stadt: ${vendor.city}'),
                    Text('IBAN: ${vendor.iban}'),
                    Text('BIC: ${vendor.bic}'),
                    Text('Bank: ${vendor.bank}'),
                    Text('Steuernummer: ${vendor.taxNr}'),
                    Text('Umsatzsteuernummer: ${vendor.vatNr}'),
                    if (vendor.website != null) Text('Website: ${vendor.website}'),
                    Text('Adresszeile für Briefkopf: ${vendor.fullAddress}'),
                    Text('Prefix für Rechnungsnummern: ${vendor.billPrefix}'),
                    Text(
                        'Kopfzeilenbild: ${vendor.headerImage != null ? 'Vorhanden' : 'Nicht vorhanden'}'),
                  ],
                ),
              ),
            ),
            Text(' Verkäufer bearbeiten', style: Theme.of(context).textTheme.headline4),
            if (newVendor.name != null)
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        initialValue: newVendor.name,
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
                        initialValue: newVendor.address,
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
                          initialValue: newVendor.city,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Stadt'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newVendor.city = input;
                            _formKey.currentState.validate();
                            dirty = true;
                          }),
                      TextFormField(
                          initialValue: newVendor.iban,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'IBAN'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newVendor.iban = input;
                            _formKey.currentState.validate();
                            dirty = true;
                          }),
                      TextFormField(
                          initialValue: newVendor.bic,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'BIC'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newVendor.bic = input;
                            _formKey.currentState.validate();
                            dirty = true;
                          }),
                      TextFormField(
                          initialValue: newVendor.bank,
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
                          initialValue: newVendor.taxNr,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Steuernummer'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newVendor.taxNr = input;
                            _formKey.currentState.validate();
                            dirty = true;
                          }),
                      TextFormField(
                          initialValue: newVendor.vatNr,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Umsatzsteuernummer'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newVendor.vatNr = input;
                            _formKey.currentState.validate();
                            dirty = true;
                          }),
                      TextFormField(
                          initialValue: newVendor.website,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Website'),
                          onChanged: (String input) {
                            newVendor.website = input;
                            dirty = true;
                          }),
                      TextFormField(
                          initialValue: newVendor.fullAddress,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: 'Adresszeile für Briefkopf'),
                          validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                          onChanged: (String input) {
                            newVendor.fullAddress = input;
                            _formKey.currentState.validate();
                            dirty = true;
                          }),
                      ListTile(
                        title: Text('Kopfzeilenbild'),
                        subtitle:
                            Text(vendor.headerImage == null ? 'Nicht vorhanden' : 'Vorhanden'),
                        trailing: MaterialButton(
                          child: Text('Bild auswählen'),
                          onPressed: onOpenImage,
                        ),
                      ),
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

  Future<void> onOpenImage() async {
    print('get that image');
    final result = await showOpenPanel(
      initialDirectory: (await getApplicationDocumentsDirectory()).path,
      allowedFileTypes: [
        FileTypeFilterGroup(label: 'images', fileExtensions: ['png', 'jpg', 'jpeg', 'gif'])
      ],
      allowsMultipleSelection: false,
      canSelectDirectories: false,
      confirmButtonText: 'Auswählen',
    );

    if (result.canceled) {
      return;
    }

    vendor.headerImage = await File(result.paths.first).readAsBytes();

    await repo.update(vendor);
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  void initDb() async {
    //await Future<dynamic>.delayed(Duration(milliseconds: 100));
    repo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    //db = MySQLCustomerProvider();
    //await db.open('bitter', host: '127.0.0.1', port: 5432, user: 'ltappe', password: 'stehlen1');
    vendor = await repo.selectSingle(widget.id);
    if (vendor == null) {
      Navigator.pop(context);
      return null;
    }
    setState(() {
      newVendor = vendor;
      return vendor;
    });
  }

  void onDeleteVendor() async {
    var result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Soll dieser Verkäufer wirlich gelöscht werden?'),
              actions: <Widget>[
                MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Nein')),
                MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Ja')),
              ],
            ));
    if (result == 1) {
      await repo.delete(widget.id);
      Navigator.pop(context, true);
    }
  }

  void onPopRoute() async {
    if (dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Es gibt möglicherweise ungespeicherte Änderungen an diesem Verkäufer. Vor dem Verlassen abspeichern?'),
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
          await onSaveVendor();
          break;
        default:
          return;
      }
    }

    await Navigator.pop(context, changed);
  }

  void onSaveVendor() async {
    if (_formKey.currentState.validate()) {
      await repo.update(newVendor);
      dirty = false;
      vendor = await repo.selectSingle(widget.id);
      setState(() => vendor);
    }
  }
}
