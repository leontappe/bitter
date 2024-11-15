import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../util/path_util.dart';
import '../../widgets/database_error_watcher.dart';

class BackupPage extends StatefulWidget {
  @override
  _BackupPageState createState() => _BackupPageState();
}

class Operation {
  final DateTime started;
  DateTime finished;
  bool success = false;

  String result;

  Operation(this.started);

  void finish({bool success = true, String result}) {
    this.result = result;
    finished = DateTime.now();
    this.success = success;
  }

  @override
  String toString() => '[Operation - started:$started. finished:$finished, success:$success]';
}

class RecoveryChoice {
  bool _all = false;
  bool _bills = false;
  bool _customers = false;
  bool _drafts = false;
  bool _items = false;
  bool _vendors = false;

  RecoveryChoice();

  bool get all => _all;
  set all(bool a) {
    _bills = a;
    _customers = a;
    _drafts = a;
    _items = a;
    _vendors = a;
    _all = a;
  }

  bool get bills => _bills;
  set bills(bool a) {
    if (!a) _all = false;
    _bills = a;
    if (everything) _all = true;
  }

  bool get customers => _customers;
  set customers(bool a) {
    if (!a) _all = false;
    _customers = a;
    if (everything) _all = true;
  }

  bool get drafts => _drafts;
  set drafts(bool a) {
    if (!a) _all = false;
    _drafts = a;
    if (everything) _all = true;
  }

  bool get everything => _bills && _customers && _drafts && _items && _vendors;
  bool get isset => _bills || _customers || _drafts || _items || _vendors;

  bool get items => _items;
  set items(bool a) {
    if (!a) _all = false;
    _items = a;
    if (everything) _all = true;
  }

  bool get vendors => _vendors;
  set vendors(bool a) {
    if (!a) _all = false;
    _vendors = a;
    if (everything) _all = true;
  }
}

class _BackupPageState extends State<BackupPage> {
  BillRepository<DatabaseProvider> billRepo;
  CustomerRepository<DatabaseProvider> customerRepo;
  DraftRepository<DatabaseProvider> draftRepo;
  ItemRepository<DatabaseProvider> itemRepo;
  VendorRepository<DatabaseProvider> vendorRepo;

  bool busy = false;
  List<Operation> backups = <Operation>[];
  List<Operation> restores = <Operation>[];

  String archivePath;
  Uint8List archiveData;
  bool overwriteRestore = false;
  RecoveryChoice recoveryChoice = RecoveryChoice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup und Wiederherstellung'),
      ),
      body: DatabaseErrorWatcher(
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            Card(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.0, 8.0, 64.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Backup/Export', style: Theme.of(context).textTheme.headline5),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: !busy ? onStartBackup : null,
                          child: Text('Backup starten'),
                        ),
                        Spacer(),
                        if (busy) CircularProgressIndicator(),
                      ],
                    ),
                    ...backups.map<Widget>((Operation e) => Text(
                        'Backup gestartet um ${DateFormat.Hms().format(e.started)}' +
                            (e.finished != null
                                ? ' und beendet um ${DateFormat.Hms().format(e.finished)} (${(e.finished.millisecondsSinceEpoch - e.started.millisecondsSinceEpoch) / 1000} Sekunden)\nAusgabe in: ${e.result}'
                                : ''))),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Wiederherstellung', style: Theme.of(context).textTheme.headline5),
                    MaterialButton(
                        onPressed: onOpenArchiveChooser,
                        child: Text('Archiv zur Wiederherstellung wählen')),
                    if (archivePath != null) Text(' Aktuelle Auswahl: $archivePath'),
                    Divider(height: 16.0),
                    CheckboxListTile(
                      title: Text('Vorhandene Daten vor dem Wiederherstellen löschen?'),
                      value: overwriteRestore,
                      onChanged: (bool input) => setState(() => overwriteRestore = input),
                    ),
                    Divider(height: 16.0),
                    Text('Datensätze zur Wiederherstellung wählen',
                        style: Theme.of(context).textTheme.headline6),
                    CheckboxListTile(
                      value: recoveryChoice.all,
                      onChanged: (bool input) => setState(() => recoveryChoice.all = input),
                      title: Text('Alle'),
                    ),
                    CheckboxListTile(
                      value: recoveryChoice.bills,
                      onChanged: (bool input) => setState(() => recoveryChoice.bills = input),
                      title: Text('Rechnungen'),
                    ),
                    CheckboxListTile(
                      value: recoveryChoice.customers,
                      onChanged: (bool input) => setState(() => recoveryChoice.customers = input),
                      title: Text('Kunden'),
                    ),
                    CheckboxListTile(
                      value: recoveryChoice.drafts,
                      onChanged: (bool input) => setState(() => recoveryChoice.drafts = input),
                      title: Text('Entwürfe'),
                    ),
                    CheckboxListTile(
                      value: recoveryChoice.items,
                      onChanged: (bool input) => setState(() => recoveryChoice.items = input),
                      title: Text('Artikel'),
                    ),
                    CheckboxListTile(
                      value: recoveryChoice.vendors,
                      onChanged: (bool input) => setState(() => recoveryChoice.vendors = input),
                      title: Text('Verkäufer'),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: onStartRecovery, child: Text('Wiederherstellung starten')),
                        Spacer(),
                        if (busy) CircularProgressIndicator(),
                      ],
                    ),
                    ...restores.map<Widget>((Operation e) => Text(
                        'Wiederherstellung gestartet um ${DateFormat.Hms().format(e.started)}' +
                            (e.finished != null
                                ? ' und beendet um ${DateFormat.Hms().format(e.finished)} (${(e.finished.millisecondsSinceEpoch - e.started.millisecondsSinceEpoch) / 1000} Sekunden)\n${e.result}'
                                : ''))),
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

  Future<void> initDb() async {
    billRepo = BillRepository(InheritedDatabase.of(context));
    customerRepo = CustomerRepository(InheritedDatabase.of(context));
    draftRepo = DraftRepository(InheritedDatabase.of(context));
    itemRepo = ItemRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));

    await billRepo.setUp();
    await customerRepo.setUp();
    await draftRepo.setUp();
    await itemRepo.setUp();
    await vendorRepo.setUp();
  }

  void onOpenArchiveChooser() async {
    String path;
    Uint8List data;
    if (kIsWeb || (!kIsWeb && (Platform.isIOS || Platform.isAndroid))) {
      final dialogResult =
          await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);

      if (dialogResult == null || !dialogResult.isSinglePick) {
        return;
      }

      path = dialogResult.files.single.path;
      data = dialogResult.files.single.bytes;
    } else {
      final result = await openFile(acceptedTypeGroups: [
        XTypeGroup(label: 'zip-archive', extensions: ['zip'])
      ]);

      path = result.path;
      data = await result.readAsBytes();
    }

    if (path == null || data == null) return;

    setState(() {
      archivePath = path;
      archiveData = data;
    });
  }

  void onStartBackup() async {
    final startTime = DateTime.now();

    setState(() => backups.add(Operation(startTime)));

    final backupPath = '${await getDataPath()}/backup';
    await Directory(backupPath).create();

    // collect data from repos and store as csv
    // temp csv files are stored under bitter/backup/csv
    final csvDir = await Directory('$backupPath/csv').create();

    final bills = await billRepo.select();
    final customers = await customerRepo.select();
    final drafts = await draftRepo.select();
    final items = await itemRepo.select();
    final vendors = await vendorRepo.select();

    const csvConverter = ListToCsvConverter();

    if (bills.isNotEmpty) {
      final billCsv = <List<dynamic>>[bills.first.toMap.keys.toList()];
      billCsv.addAll(bills.map<List<dynamic>>((e) => e.toMap.values.toList()));
      await File('${csvDir.path}/bills.csv').writeAsString(csvConverter.convert(billCsv));
    }

    if (customers.isNotEmpty) {
      final customerCsv = <List<dynamic>>[customers.first.toMap.keys.toList()];
      customerCsv.addAll(customers.map<List<dynamic>>((e) => e.toMap.values.toList()));
      await File('${csvDir.path}/customers.csv').writeAsString(csvConverter.convert(customerCsv));
    }

    if (drafts.isNotEmpty) {
      final draftCsv = <List<dynamic>>[drafts.first.toMap.keys.toList()];
      draftCsv.addAll(drafts.map<List<dynamic>>((e) => e.toMap.values.toList()));
      await File('${csvDir.path}/drafts.csv').writeAsString(csvConverter.convert(draftCsv));
    }

    if (items.isNotEmpty) {
      final itemCsv = <List<dynamic>>[items.first.toMap.keys.toList()];
      itemCsv.addAll(items.map<List<dynamic>>((e) => e.toMap.values.toList()));
      await File('${csvDir.path}/items.csv').writeAsString(csvConverter.convert(itemCsv));
    }

    if (vendors.isNotEmpty) {
      final vendorCsv = <List<dynamic>>[vendors.first.toMap.keys.toList()];
      vendorCsv.addAll(vendors.map<List<dynamic>>((e) => e.toMap.values.toList()));
      await File('${csvDir.path}/vendors.csv').writeAsString(csvConverter.convert(vendorCsv));
    }

    // write a zip file with collected data
    final encoder = ZipFileEncoder();
    final archivePath =
        '$backupPath/backup_${startTime.toString().replaceAll(':', '-').replaceAll(' ', '_').replaceAll('.', '-')}.zip';
    encoder.create(archivePath);
    encoder.addDirectory(csvDir);
    encoder.close();

    setState(() => backups.last.finish(result: archivePath));
  }

  void onStartRecovery() async {
    if (archivePath == null || archiveData == null) {
      await showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
              'Du musst eine Backupdatei (Zip-Archiv) zum Wiederherstellen auswählen.\nBitte wähle eine Datei aus und versuche es noch ein Mal.'),
          actions: [MaterialButton(onPressed: () => Navigator.pop(context), child: Text('Okay'))],
        ),
      );
      return;
    }
    if (!recoveryChoice.isset) {
      await showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
              'Du musst mindestens einen der Datensätze zur Wiederherstellung wählen.\nBitte wähle die zur Wiederherstellung vorgemerkten Datensätze aus und versuche es noch ein Mal.'),
          actions: [MaterialButton(onPressed: () => Navigator.pop(context), child: Text('Okay'))],
        ),
      );
      return;
    }
    final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Möchtest du wirklich die Wiederherstellung starten?'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Nein doch nicht!'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Ja, bitte starten'),
                ),
              ],
            ));
    if (!result) return;

    setState(() => restores.add(Operation(DateTime.now())));

    // load and unzip file, then parse objects for all selected tables and insert them via corresponding repos

    final db = InheritedDatabase.of(context);

    final archive = ZipDecoder().decodeBytes(archiveData);

    for (ArchiveFile file in archive) {
      if (recoveryChoice.customers && file.name.contains('customers')) {
        if (overwriteRestore) {
          await customerRepo.setUp();
          await db.dropTable('customers');
          await customerRepo.setUp();
        }
        _mapFileContent(file.content as Uint8List)
            .map((Map<String, dynamic> e) => Customer.fromMap(e))
            .forEach((Customer c) => customerRepo.insert(c));
      } else if (recoveryChoice.vendors && file.name.contains('vendors')) {
        if (overwriteRestore) {
          await vendorRepo.setUp();
          await db.dropTable('vendors');
          await vendorRepo.setUp();
        }
        _mapFileContent(file.content as Uint8List)
            .map((Map<String, dynamic> e) => Vendor.fromMap(e))
            .forEach((Vendor v) => vendorRepo.insert(v));
      } else if (recoveryChoice.items && file.name.contains('items')) {
        if (overwriteRestore) {
          await itemRepo.setUp();
          await db.dropTable('items');
          await itemRepo.setUp();
        }
        _mapFileContent(file.content as Uint8List)
            .map((Map<String, dynamic> e) => Item.fromDbMap(e))
            .forEach((Item i) => itemRepo.insert(i));
      } else if (recoveryChoice.drafts && file.name.contains('drafts')) {
        if (overwriteRestore) {
          await draftRepo.setUp();
          await db.dropTable('drafts');
          await draftRepo.setUp();
        }
        _mapFileContent(file.content as Uint8List)
            .map((Map<String, dynamic> e) => Draft.fromMap(e))
            .forEach((Draft d) => draftRepo.insert(d));
      } else if (recoveryChoice.bills && file.name.contains('bills')) {
        if (overwriteRestore) {
          await billRepo.setUp();
          await db.dropTable('bills');
          await billRepo.setUp();
        }
        _mapFileContent(file.content as Uint8List)
            .map((Map<String, dynamic> e) => Bill.fromMap(e))
            .forEach((Bill b) => billRepo.insert(b));
      }
    }
    setState(() => restores.first.finish(result: 'Wiederherstellung abgeschlossen'));
  }

  List<Map<String, dynamic>> _mapFileContent(Uint8List file) {
    final converter = CsvToListConverter();
    final csvList = converter.convert<dynamic>(utf8.decode(file));
    final headers = csvList.first.map<String>((dynamic e) => e.toString());
    final mappedList = <Map<String, dynamic>>[];
    for (var i = 1; i < csvList.length; i++) {
      final map = Map<String, dynamic>.fromIterables(headers, csvList[i]);
      map.removeWhere((String key, dynamic value) => (value == null || value == 'null'));
      mappedList.add(map);
    }
    return mappedList;
  }
}
