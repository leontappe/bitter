import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:bitter/src/providers/database_provider.dart';
import 'package:bitter/src/providers/inherited_database.dart';
import 'package:csv/csv.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../repositories/bill_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/vendor_repository.dart';

class Operation {
  final DateTime started;
  DateTime finished;
  bool success = false;

  String result;

  Operation(this.started);

  @override
  String toString() => '[Operation - started:$started. finished:$finished, success:$success]';

  void finish({bool success = true, String result}) {
    this.result = result;
    finished = DateTime.now();
    this.success = success;
  }
}

class RecoveryChoice {
  bool bills = false;
  bool customers = false;
  bool drafts = false;
  bool items = false;
  bool vendors = false;

  RecoveryChoice();

  bool get isset => bills || customers || drafts || items || vendors;
}

class BackupPage extends StatefulWidget {
  @override
  _BackupPageState createState() => _BackupPageState();
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
  bool overwriteRestore = false;
  RecoveryChoice recoveryChoice = RecoveryChoice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup und Wiederherstellung'),
      ),
      body: ListView(
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
                      RaisedButton(
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
                  Divider(),
                  CheckboxListTile(
                    title: Text('Vorhandene Daten vor dem Wiederherstellen löschen?'),
                    value: overwriteRestore,
                    onChanged: (bool input) => setState(() => overwriteRestore = input),
                  ),
                  Divider(),
                  Text('Datensätze zur Wiederherstellung wählen',
                      style: Theme.of(context).textTheme.headline6),
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
                      RaisedButton(
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
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    billRepo = BillRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    draftRepo = DraftRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    itemRepo = ItemRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);

    await billRepo.setUp();
    await customerRepo.setUp();
    await draftRepo.setUp();
    await itemRepo.setUp();
    await vendorRepo.setUp();
  }

  void onOpenArchiveChooser() async {
    List<String> result;
    if (!Platform.isWindows) {
      final dialogResult = await showOpenPanel(
        //initialDirectory: (await getApplicationDocumentsDirectory()).path,
        allowedFileTypes: [
          FileTypeFilterGroup(label: 'archives', fileExtensions: ['zip'])
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
          title: Text('Wiederherstellungsdatei laden'),
          content: Text(
              'Um ein Archiv zum Wiederherstellen auszuwählen die entsprechende Datei unter Dokumente\\bitter\\config platzieren und danach \'Fertig\' drücken.'),
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
        final backups =
            docs.listSync(followLinks: false).where((e) => e.path.contains('.zip')).toList();
        backups.removeWhere(
            (element) => element.path.contains('.json') || element.path.contains('.db'));

        if (backups.isEmpty) {
          return;
        } else {
          result = List.from(backups.map<String>((e) => e.path));
        }
      }
    }

    setState(() => archivePath = result.first);
  }

  void onStartBackup() async {
    final startTime = DateTime.now();

    setState(() => backups.add(Operation(startTime)));

    // set up paths for all platforms
    String downloadsPath;
    if (Platform.isWindows) {
      downloadsPath = (await getApplicationDocumentsDirectory()).path;
    } else {
      downloadsPath = (await getDownloadsDirectory()).path;
    }
    final backupPath = '${downloadsPath}/bitter/backup';
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

    final billCsv = <List<dynamic>>[bills.first.toMap.keys.toList()];
    billCsv.addAll(bills.map<List<dynamic>>((e) => e.toMap.values.toList()));
    await File('${csvDir.path}/bills.csv').writeAsString(csvConverter.convert(billCsv));

    final customerCsv = <List<dynamic>>[customers.first.toMap.keys.toList()];
    customerCsv.addAll(customers.map<List<dynamic>>((e) => e.toMap.values.toList()));
    await File('${csvDir.path}/customers.csv').writeAsString(csvConverter.convert(customerCsv));

    final draftCsv = <List<dynamic>>[drafts.first.toMap.keys.toList()];
    draftCsv.addAll(drafts.map<List<dynamic>>((e) => e.toMap.values.toList()));
    await File('${csvDir.path}/drafts.csv').writeAsString(csvConverter.convert(draftCsv));

    final itemCsv = <List<dynamic>>[items.first.toMap.keys.toList()];
    itemCsv.addAll(items.map<List<dynamic>>((e) => e.toMap.values.toList()));
    await File('${csvDir.path}/items.csv').writeAsString(csvConverter.convert(itemCsv));

    final vendorCsv = <List<dynamic>>[vendors.first.toMap.keys.toList()];
    vendorCsv.addAll(vendors.map<List<dynamic>>((e) => e.toMap.values.toList()));
    await File('${csvDir.path}/vendors.csv').writeAsString(csvConverter.convert(vendorCsv));

    // write a zip file with collected data
    final encoder = ZipFileEncoder();
    final archivePath =
        '$backupPath/backup_${startTime.toString().replaceAll(':', '-').replaceAll(' ', '_').replaceAll('.', '-')}.zip';
    encoder.create(archivePath);
    await encoder.addDirectory(csvDir);
    encoder.close();

    setState(() => backups.last.finish(result: archivePath));
  }

  void onStartRecovery() async {
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
                RaisedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Nein doch nicht!'),
                ),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Ja, bitte starten'),
                ),
              ],
            ));
    if (!result) return;

    setState(() => restores.add(Operation(DateTime.now())));

    // TODO: load and unzip file, then parse objects for all selected tables and insert them via corresponding repos
  }
}
