import 'dart:io';
import 'dart:typed_data';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../widgets/vendor_card.dart';
import '../../models/vendor.dart';
import '../../providers/inherited_database.dart';
import '../../providers/mysql_provider.dart';
import '../../repositories/vendor_repository.dart';

class VendorPage extends StatefulWidget {
  final int id;

  VendorPage({this.id});

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
          leading: IconButton(
            tooltip: 'Zurück',
            icon: Icon((widget.id != null) ? Icons.arrow_back_ios : Icons.cancel),
            onPressed: onPopRoute,
          ),
          title: Text((widget.id != null) ? 'Verkäuferansicht' : 'Verkäufer hinzufügen'),
          actions: <Widget>[
            if (widget.id != null)
              IconButton(
                tooltip: 'Diesen Verkäufer löschen',
                icon: Icon(Icons.delete),
                onPressed: onDeleteVendor,
              ),
            IconButton(
              tooltip: 'Verkäufer abspeichern',
              icon: Icon(Icons.save),
              onPressed: onSaveVendor,
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            if (widget.id != null)
              Text(' Aktuelle Informationen', style: Theme.of(context).textTheme.headline4),
            if (widget.id != null) VendorCard(vendor: vendor),
            if (widget.id != null)
              Text(' Verkäufer bearbeiten', style: Theme.of(context).textTheme.headline4),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, (widget.id != null) ? 16.0 : 8.0, 16.0, 8.0),
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
                    TextFormField(
                        maxLines: 1,
                        initialValue: newVendor.billPrefix,
                        decoration:
                            InputDecoration(labelText: 'Prefix für Rechnungsnummern (Zweistellig)'),
                        validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                        onChanged: (String input) {
                          newVendor.billPrefix = input;
                          _formKey.currentState.validate();
                          dirty = true;
                        }),
                    ListTile(
                      title: Text('Kopfzeilenbild'),
                      subtitle: (newVendor.headerImage != null)
                          ? Image.memory(Uint8List.fromList(vendor.headerImage))
                          : Text('Nicht vorhanden'),
                      trailing: (newVendor.headerImage != null)
                          ? MaterialButton(onPressed: onClearImage, child: Text('Bild entfernen'))
                          : MaterialButton(
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

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  void initDb() async {
    repo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    if (widget.id != null) {
      vendor = await repo.selectSingle(widget.id);
      if (vendor == null) {
        Navigator.pop(context);
        return null;
      }
      newVendor = vendor;
    } else {
      vendor = newVendor;
    }
    setState(() {
      return vendor;
    });
  }

  void onDeleteVendor() async {
    var result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Soll dieser Verkäufer wirlich gelöscht werden?'),
              actions: <Widget>[
                MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Verwerfen')),
                MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Speichern')),
              ],
            ));
    if (result == 1) {
      await repo.delete(widget.id);
      Navigator.pop(context, true);
    }
  }

  Future<void> onOpenImage() async {
    if (!Platform.isWindows) {
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

      newVendor.headerImage = await File(result.paths.first).readAsBytes();
      setState(() => newVendor);
      await repo.update(newVendor);
    } else {
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Kopfzeilenbild festlegen'),
          content: Text('''
Um ein Kopfzeilenbild für diesen Verkäufer festzulegen, bitte ein Bild unter Dokumente\\bitter\\config platzieren und danach \'Fertig\' drücken. 
(Das Bild löscht sich dort selber nachdem bitter es in die Datenbank kopiert hat)
'''),
          actions: [
            MaterialButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.pop(context, false),
            ),
            MaterialButton(
              child: Text('Fertig'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
      if (result) {
        final docPath = '${(await getApplicationDocumentsDirectory()).path}\\bitter\\config';
        final docs = Directory(docPath);
        var images = docs
            .listSync(followLinks: false)
            .where((e) =>
                e.path.contains('.png') ||
                e.path.contains('.jpg') ||
                e.path.contains('.jpeg') ||
                e.path.contains('.gif'))
            .toList();
        images.removeWhere((element) => element.path.contains('.json'));

        if (images.isEmpty) return;

        newVendor.headerImage = await File(images.first.path).readAsBytes();
        setState(() => newVendor);
        await repo.update(newVendor);

        await File(images.first.path).delete();
      } else {
        return;
      }
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
                  MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Verwerfen')),
                  MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Speichern')),
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

  Future<void> onSaveVendor() async {
    if (_formKey.currentState.validate()) {
      if (widget.id != null) {
        await repo.update(newVendor);
        dirty = false;
        vendor = await repo.selectSingle(widget.id);
        setState(() => vendor);
      } else {
        await repo.insert(newVendor);
        Navigator.pop<bool>(context, true);
      }
    }
  }

  void onClearImage() {
    setState(() => newVendor.headerImage = null);
    dirty = true;
  }
}
