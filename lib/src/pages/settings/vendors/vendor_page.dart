import 'dart:io';
import 'dart:typed_data';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/reminder.dart';
import '../../../models/vendor.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/inherited_database.dart';
import '../../../repositories/vendor_repository.dart';
import '../../../widgets/database_error_watcher.dart';
import '../../../widgets/info_cards/vendor_card.dart';

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

  bool busy = false;

  @override
  Widget build(BuildContext context) {
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
              onPressed: busy ? null : onDeleteVendor,
            ),
          IconButton(
            tooltip: 'Verkäufer abspeichern',
            icon: Icon(Icons.save),
            onPressed: busy ? null : onSaveVendor,
          ),
        ],
      ),
      body: DatabaseErrorWatcher(
        child: (busy)
            ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
            : ListView(
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
                            initialValue: newVendor.manager,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Organisation'),
                            onChanged: (String input) {
                              newVendor.manager = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.contact,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Ansprechpartner'),
                            onChanged: (String input) {
                              newVendor.contact = input;
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
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  expands: false,
                                  initialValue: newVendor.zipCode?.toString() ?? '',
                                  maxLines: 1,
                                  decoration: InputDecoration(labelText: 'Postleitzahl'),
                                  keyboardType: TextInputType.numberWithOptions(),
                                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                                  onChanged: (String input) {
                                    newVendor.zipCode = int.parse(input);
                                    _formKey.currentState.validate();
                                    dirty = true;
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  expands: false,
                                  initialValue: newVendor.city,
                                  maxLines: 1,
                                  decoration: InputDecoration(labelText: 'Stadt'),
                                  validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                                  onChanged: (String input) {
                                    newVendor.city = input;
                                    _formKey.currentState.validate();
                                    dirty = true;
                                  },
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: newVendor.iban,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'IBAN'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.iban = input;
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.bic,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'BIC'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.bic = input;
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
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
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.taxNr,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Steuernummer'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.taxNr = input;
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.vatNr,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Umsatzsteuernummer'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.vatNr = input;
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.email,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'E-Mail'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.email = input;
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.website,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Website'),
                            onChanged: (String input) {
                              newVendor.website = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.fullAddress,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Adresszeile für Briefkopf'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.fullAddress = input;
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 1,
                            initialValue: newVendor.billPrefix,
                            decoration: InputDecoration(labelText: 'Prefix für Rechnungsnummern'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.billPrefix = input;
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 1,
                            initialValue: newVendor.defaultDueDays?.toString() ?? '14',
                            keyboardType: TextInputType.numberWithOptions(),
                            decoration: InputDecoration(
                                labelText: 'Standard Zahlungsfrist', suffixText: 'Tage'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.defaultDueDays = int.parse(input);
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 1,
                            initialValue: newVendor.defaultTax?.toString() ?? '19',
                            keyboardType: TextInputType.numberWithOptions(),
                            decoration: InputDecoration(
                                labelText: 'Standard Umsatzsteuer', suffixText: '%'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newVendor.defaultTax = int.parse(input);
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 3,
                            initialValue: newVendor.defaultComment,
                            decoration: InputDecoration(labelText: 'Standard Rechnungskommentar'),
                            onChanged: (String input) {
                              newVendor.defaultComment = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.userMessageLabel,
                            maxLines: 1,
                            decoration: InputDecoration(
                                labelText: 'Label für benutzerdefinierten Rechnungskommentar'),
                            onChanged: (String input) {
                              newVendor.userMessageLabel = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 1,
                            initialValue: newVendor.reminderFee?.toString() ?? '0',
                            keyboardType: TextInputType.numberWithOptions(),
                            decoration:
                                InputDecoration(labelText: 'Standard Mahngebühr', suffixText: '€'),
                            onChanged: (String input) {
                              newVendor.reminderFee = int.parse(input);
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 1,
                            initialValue: newVendor.reminderDeadline?.toString() ?? '14',
                            keyboardType: TextInputType.numberWithOptions(),
                            decoration: InputDecoration(
                                labelText: 'Standardfrist für Mahnungen', suffixText: 'Tage'),
                            onChanged: (String input) {
                              newVendor.reminderDeadline = int.parse(input);
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.reminderTitles[ReminderIteration.first] ?? '',
                            decoration:
                                InputDecoration(labelText: 'Standardtitel für erste Mahnung'),
                            onChanged: (String input) {
                              newVendor.reminderTitles[ReminderIteration.first] = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.reminderTitles[ReminderIteration.second] ?? '',
                            decoration:
                                InputDecoration(labelText: 'Standardtitel für zweite Mahnung'),
                            onChanged: (String input) {
                              newVendor.reminderTitles[ReminderIteration.second] = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newVendor.reminderTitles[ReminderIteration.third] ?? '',
                            decoration:
                                InputDecoration(labelText: 'Standardtitel für dritte Mahnung'),
                            onChanged: (String input) {
                              newVendor.reminderTitles[ReminderIteration.third] = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 3,
                            initialValue: newVendor.reminderTexts[ReminderIteration.first] ?? '',
                            decoration:
                                InputDecoration(labelText: 'Standardtext für erste Mahnung'),
                            onChanged: (String input) {
                              newVendor.reminderTexts[ReminderIteration.first] = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 3,
                            initialValue: newVendor.reminderTexts[ReminderIteration.second] ?? '',
                            decoration:
                                InputDecoration(labelText: 'Standardtext für zweite Mahnung'),
                            onChanged: (String input) {
                              newVendor.reminderTexts[ReminderIteration.second] = input;
                              dirty = true;
                            },
                          ),
                          TextFormField(
                            maxLines: 3,
                            initialValue: newVendor.reminderTexts[ReminderIteration.third] ?? '',
                            decoration:
                                InputDecoration(labelText: 'Standardtext für dritte Mahnung'),
                            onChanged: (String input) {
                              newVendor.reminderTexts[ReminderIteration.third] = input;
                              dirty = true;
                            },
                          ),
                          ListTile(title: Text('Kopfzeilenbilder')),
                          ListTile(
                            title: Text('Rechtes Kopfzeilenbild'),
                            subtitle: (newVendor.headerImageRight != null)
                                ? Image.memory(Uint8List.fromList(vendor.headerImageRight))
                                : Text('Nicht vorhanden'),
                            trailing: (newVendor.headerImageRight != null)
                                ? MaterialButton(
                                    onPressed: () => onClearImage(HeaderImage.right),
                                    child: Text('Bild entfernen'))
                                : MaterialButton(
                                    child: Text('Bild auswählen'),
                                    onPressed: () => onOpenImage(HeaderImage.right),
                                  ),
                          ),
                          ListTile(
                            title: Text('Mittleres Kopfzeilenbild'),
                            subtitle: (newVendor.headerImageCenter != null)
                                ? Image.memory(Uint8List.fromList(vendor.headerImageCenter))
                                : Text('Nicht vorhanden'),
                            trailing: (newVendor.headerImageCenter != null)
                                ? MaterialButton(
                                    onPressed: () => onClearImage(HeaderImage.center),
                                    child: Text('Bild entfernen'))
                                : MaterialButton(
                                    child: Text('Bild auswählen'),
                                    onPressed: () => onOpenImage(HeaderImage.center),
                                  ),
                          ),
                          ListTile(
                            title: Text('Linkes Kopfzeilenbild'),
                            subtitle: (newVendor.headerImageLeft != null)
                                ? Image.memory(Uint8List.fromList(vendor.headerImageLeft))
                                : Text('Nicht vorhanden'),
                            trailing: (newVendor.headerImageLeft != null)
                                ? MaterialButton(
                                    onPressed: () => onClearImage(HeaderImage.left),
                                    child: Text('Bild entfernen'))
                                : MaterialButton(
                                    child: Text('Bild auswählen'),
                                    onPressed: () => onOpenImage(HeaderImage.left),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  void initDb() async {
    if (mounted) setState(() => busy = true);
    repo = VendorRepository<DatabaseProvider>(InheritedDatabase.of(context));
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
    if (mounted) setState(() => busy = false);
  }

  void onClearImage(HeaderImage image) {
    switch (image) {
      case HeaderImage.right:
        newVendor.headerImageRight = null;
        break;
      case HeaderImage.center:
        newVendor.headerImageCenter = null;
        break;
      case HeaderImage.left:
        newVendor.headerImageLeft = null;
        break;
      default:
    }
    setState(() => newVendor);
    dirty = true;
  }

  void onDeleteVendor() async {
    var result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Soll dieser Verkäufer wirlich gelöscht werden?'),
              actions: <Widget>[
                MaterialButton(
                    onPressed: () => Navigator.pop(context, 0), child: Text('Verwerfen')),
                MaterialButton(
                    onPressed: () => Navigator.pop(context, 1), child: Text('Speichern')),
              ],
            ));
    if (result == 1) {
      if (mounted) setState(() => busy = true);
      await repo.delete(widget.id);
      if (mounted) setState(() => busy = false);
      Navigator.pop(context, true);
    }
  }

  Future<void> onOpenImage(HeaderImage image) async {
    List<String> result;
    if (!Platform.isWindows) {
      final dialogResult = await showOpenPanel(
        //initialDirectory: (await getApplicationDocumentsDirectory()).path,
        allowedFileTypes: [
          FileTypeFilterGroup(label: 'images', fileExtensions: ['png', 'jpg', 'jpeg', 'gif'])
        ],
        allowsMultipleSelection: false,
        canSelectDirectories: false,
        confirmButtonText: 'Auswählen',
      );

      if (dialogResult.canceled) {
        return;
      } else {
        result = dialogResult.paths;
      }
    } else {
      final dialogResult = await showDialog<bool>(
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
      if (dialogResult) {
        final docPath = '${(await getApplicationDocumentsDirectory()).path}\\bitter\\config';
        final docs = Directory(docPath);
        final images = docs
            .listSync(followLinks: false)
            .where((e) =>
                e.path.contains('.png') ||
                e.path.contains('.jpg') ||
                e.path.contains('.jpeg') ||
                e.path.contains('.gif'))
            .toList();
        images.removeWhere(
            (element) => element.path.contains('.json') || element.path.contains('.db'));

        if (images.isEmpty) {
          return;
        } else {
          result = List.from(images.map<String>((e) => e.path));
        }
      }
    }

    switch (image) {
      case HeaderImage.right:
        newVendor.headerImageRight = await File(result.first).readAsBytes();
        break;
      case HeaderImage.center:
        newVendor.headerImageCenter = await File(result.first).readAsBytes();
        break;
      case HeaderImage.left:
        newVendor.headerImageLeft = await File(result.first).readAsBytes();
        break;
      default:
    }

    if (Platform.isWindows) {
      await File(result.first).delete();
    }

    setState(() => newVendor);
    await repo.update(newVendor);
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
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, 0), child: Text('Verwerfen')),
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, 1), child: Text('Speichern')),
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
      if (mounted) setState(() => busy = true);
      if (widget.id != null) {
        await repo.update(newVendor);
        dirty = false;
        vendor = await repo.selectSingle(widget.id);
        setState(() => busy = false);
      } else {
        await repo.insert(newVendor);
        Navigator.pop<bool>(context, true);
      }
    }
  }
}
