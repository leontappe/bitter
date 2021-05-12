import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import '../../models/bill.dart';
import '../../models/reminder.dart';
import '../../pdf/reminder_generator.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../util/format_util.dart';
import '../../util/path_util.dart';
import '../../widgets/database_error_watcher.dart';
import '../../widgets/info_cards/customer_card.dart';
import '../../widgets/info_cards/items_card.dart';
import '../../widgets/info_cards/vendor_card.dart';
import '../../widgets/option_dialog.dart';
import '../drafts/draft_creator.dart';
import 'save_bill_button.dart';

class BillPage extends StatefulWidget {
  final int id;

  BillPage({this.id});

  @override
  _BillPageState createState() => _BillPageState();
}

enum ReminderOption {
  save,
  delete,
}

class _BillPageState extends State<BillPage> {
  final _key = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BillRepository repo;
  VendorRepository vendorRepo;
  DraftRepository draftRepo;

  Bill bill;

  Vendor vendor;

  bool dirty = false;

  bool busy = false;

  final GlobalKey<FormState> _reminderFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) => IconButton(
                  tooltip: 'Zurück',
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => onPopRoute(context),
                )),
        title: Text(bill?.billNr ?? ''),
        actions: [
          IconButton(icon: Icon(Icons.ios_share), onPressed: (!busy) ? onExportDraft : null),
          IconButton(icon: Icon(Icons.save), onPressed: (!busy) ? onSaveBill : null),
          SaveBillButton(billId: (!busy) ? bill.id : null),
        ],
      ),
      body: DatabaseErrorWatcher(
          child: (busy)
              ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        title: Text(bill.billNr, style: Theme.of(context).textTheme.headline6),
                        subtitle: Text('Erstellt am ${formatDateTime(bill.created)}'),
                        trailing: Text('von ${bill.editor}'),
                      ),
                      if (bill.userMessage != null)
                        ListTile(
                          title: Text((bill.vendor.userMessageLabel ??
                                  'Benutzerdefinierter Rechnungskommentar') +
                              ': ${bill.userMessage}'),
                        ),
                      if (bill.comment != null)
                        ListTile(title: Text('Rechnungskommentar: ${bill.comment}')),
                      ListTile(
                        title: DropdownButton<BillStatus>(
                          style: Theme.of(context).textTheme.headline6,
                          isExpanded: false,
                          hint: Text('${bill?.status ?? BillStatus.unpaid}'),
                          value: bill?.status ?? BillStatus.unpaid,
                          items: [
                            DropdownMenuItem(value: BillStatus.unpaid, child: Text('Unbezahlt')),
                            DropdownMenuItem(value: BillStatus.paid, child: Text('Bezahlt')),
                            DropdownMenuItem(value: BillStatus.cancelled, child: Text('Storniert')),
                          ],
                          onChanged: (BillStatus v) {
                            setState(() => bill.status = v);
                            dirty = true;
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bill != null)
                              Text('Lieferdatum/Leistungsdatum: ${formatDate(bill.serviceDate)}'),
                            if (bill != null) Text('Zahlungsziel: ${formatDate(bill.dueDate)}'),
                          ],
                        ),
                      ),
                      if (bill.reminders != null && bill.reminders.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: bill.reminders
                              .map<Widget>((Reminder r) => Flexible(
                                  child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      margin: EdgeInsets.all(8.0),
                                      child: PopupMenuButton<ReminderOption>(
                                        tooltip: 'Menü zeigen',
                                        onSelected: (ReminderOption option) async {
                                          switch (option) {
                                            case ReminderOption.save:
                                              _onGenerateReminder(r, skipSaving: true);
                                              break;
                                            case ReminderOption.delete:
                                              final dialogResult = await showDialog<bool>(
                                                  context: context,
                                                  builder: (BuildContext context) => AlertDialog(
                                                        title: Text('Mahnung löschen?'),
                                                        content: Text(
                                                            'Solange die Rechnung nicht gespeichert wird, ist diese Änderung widerrufbar.'),
                                                        actions: [
                                                          MaterialButton(
                                                            onPressed: () =>
                                                                Navigator.of(context).pop(true),
                                                            child: Text('Ja'),
                                                          ),
                                                          MaterialButton(
                                                            onPressed: () =>
                                                                Navigator.of(context).pop(false),
                                                            child: Text('Nein'),
                                                          ),
                                                        ],
                                                      ));
                                              if (dialogResult) {
                                                _onDeleteReminder(r.iteration);
                                              }
                                              break;
                                            default:
                                          }
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<ReminderOption>>[
                                          const PopupMenuItem<ReminderOption>(
                                            value: ReminderOption.save,
                                            child: Text('Speichern'),
                                          ),
                                          const PopupMenuItem<ReminderOption>(
                                            value: ReminderOption.delete,
                                            child: Text('Löschen'),
                                          ),
                                        ],
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('${r.iteration.index + 1}. Mahnung',
                                                  style: Theme.of(context).textTheme.headline5),
                                              if (r.title != null && r.title.isNotEmpty)
                                                Text('Titel: ${r.title}'),
                                              Text('Frist: ${formatDate(r.deadline)}'),
                                              Text('Mahngebühr: ${formatFigure(r.fee)}'),
                                            ],
                                          ),
                                        ),
                                      ))))
                              .toList(),
                        ),
                      if (((bill?.status ?? BillStatus.unpaid) == BillStatus.unpaid &&
                              DateTime.now().isAfter(bill.dueDate)) &&
                          bill.reminders.length < 3)
                        ListTile(
                            title: ElevatedButton(
                          onPressed: (bill.reminders.isEmpty ||
                                  (bill.reminders.isNotEmpty &&
                                      DateTime.now().isAfter(bill.reminders.last.deadline)))
                              ? () => _onShowReminderDialog(iterationFromInt(
                                  (bill.reminders.isNotEmpty)
                                      ? bill.reminders.last.iteration.index + 1
                                      : 0))
                              : null,
                          child: Text(
                              '${(bill.reminders.isNotEmpty) ? bill.reminders.last.iteration.index + 2 : '1'}. Mahnung erstellen'),
                        )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(hintText: 'Notizen'),
                          initialValue: bill?.note ?? '',
                          onChanged: (String input) {
                            setState(() => bill.note = input);
                            dirty = true;
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Artikel', style: Theme.of(context).textTheme.headline6),
                        subtitle: ItemsCard(items: bill.items, sum: bill.sum),
                      ),
                      ListTile(
                        title: Text('Kunde', style: Theme.of(context).textTheme.headline6),
                        subtitle: CustomerCard(customer: bill.customer),
                      ),
                      ListTile(
                        title: Text('Verkäufer', style: Theme.of(context).textTheme.headline6),
                        subtitle: VendorCard(vendor: bill.vendor),
                      ),
                    ],
                  ),
                )),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = BillRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));
    draftRepo = DraftRepository(InheritedDatabase.of(context));

    if (mounted) setState(() => busy = true);

    await vendorRepo.setUp();
    await draftRepo.setUp();

    bill = await repo.selectSingle(widget.id);
    vendor = await vendorRepo.selectSingle(bill.vendor.id);

    if (mounted) setState(() => busy = false);
  }

  Future<void> onExportDraft() async {
    final draft = Draft(
      items: bill.items,
      customer: bill.customer.id,
      vendor: bill.vendor.id,
      dueDays: vendor.defaultDueDays,
      editor: bill.editor,
      serviceDate: bill.serviceDate,
      tax: vendor.defaultTax,
      comment: bill.comment,
      userMessage: bill.userMessage,
    );

    await draftRepo.insert(draft);

    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<bool>(builder: (BuildContext context) => DraftCreatorPage(draft: draft)),
        (Route route) => route.settings.name == '/home');
  }

  Future<void> onPopRoute(BuildContext context) async {
    if (dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Wenn du ohne Speichern fortfährst gehen alle hier eingebenen Daten verloren. Vor dem Verlassen abspeichern?'),
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
          Navigator.pop<bool>(context, false);
          break;
        case 1:
          if (!await onSaveBill()) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Es gibt noch Fehler und/oder fehlende Felder in dem Formular, sodass gerade nicht gespeichert werden kann.'),
              duration: Duration(seconds: 3),
            ));
          } else {
            Navigator.pop(context, true);
          }
          break;
        default:
          return;
      }
    } else {
      Navigator.pop<bool>(context, true);
    }
  }

  Future<bool> onSaveBill() async {
    if (_formKey.currentState.validate()) {
      if (mounted) setState(() => busy = true);
      await repo.update(bill);
      dirty = false;
      if (mounted) setState(() => busy = false);
      return true;
    }
    return false;
  }

  void _onDeleteReminder(ReminderIteration iteration) async {
    setState(() {
      bill.reminders.removeWhere((Reminder r) => r.iteration == iteration);
      dirty = true;
    });
  }

  void _onGenerateReminder(Reminder reminder, {bool skipSaving = false}) async {
    if (!skipSaving) {
      setState(() => bill.reminders.add(reminder));
      dirty = true;
    }

    reminder.remainder ??= bill.sum;

    final pdfData = await ReminderGenerator().getBytesFromBill(
      bill,
      await vendorRepo.selectSingle(bill.vendor.id) ?? bill.vendor,
      reminder,
      leftHeader: bill.vendor.headerImageLeft as Uint8List,
      centerHeader: bill.vendor.headerImageCenter as Uint8List,
      rightHeader: bill.vendor.headerImageRight as Uint8List,
    );

    final file = File(
        '${await getDataPath()}/${reminder.title.isNotEmpty ? reminder.title.replaceAll(' ', '_').replaceAll('.', ' ') : 'Mahnung' + (reminder.iteration.index + 1).toString()}_${bill.billNr}.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(pdfData);

    ScaffoldMessenger.of(_key.currentContext).showSnackBar(SnackBar(
      content: Text('Die Mahnung wurde erfolgreich unter ${file.path} abgespeichert.'),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Öffnen',
        onPressed: () => OpenFile.open(file.path),
        textColor: Colors.white,
      ),
    ));
  }

  void _onShowReminderDialog(ReminderIteration iteration) async {
    final reminder = Reminder(
      iteration: iteration,
      title: vendor != null && vendor.reminderTitles != null && vendor.reminderTitles.isNotEmpty
          ? vendor.reminderTitles[iteration]
          : bill.vendor?.reminderTitles[iteration] ?? '',
      text: vendor != null && vendor.reminderTexts != null && vendor.reminderTexts.isNotEmpty
          ? vendor.reminderTexts[iteration]
          : bill.vendor?.reminderTexts[iteration] ?? '',
      fee: vendor != null ? vendor.reminderFees[iteration] : bill.vendor.reminderFees[iteration],
      deadline: DateTime.now().add(Duration(
          days: vendor != null ? vendor?.reminderDeadline : bill.vendor.reminderDeadline ?? 14)),
      remainder: bill.sum,
    );

    final result = await showDialog<Reminder>(
      context: context,
      builder: (BuildContext context) => OptionDialog(
        disableCheckbox: true,
        titleText: '${iteration.index + 1}. Mahnung erstellen',
        actions: [
          MaterialButton(
              onPressed: () => Navigator.of(context).pop(null), child: Text('Abbrechen')),
          MaterialButton(
              onPressed: () {
                if (_reminderFormKey.currentState.validate()) {
                  Navigator.of(context).pop(reminder);
                }
              },
              child: Text('Mahnung erstellen')),
        ],
        children: [
          Form(
              key: _reminderFormKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mahngebühr', suffixText: '€'),
                    keyboardType: TextInputType.number,
                    initialValue: formatFigure(reminder.fee).split(' ').first,
                    validator: (String input) =>
                        (input == null || input.isEmpty) ? 'Pflichtfeld' : null,
                    onChanged: (String input) => reminder.fee = parseFloat(input),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Restbetrag', suffixText: '€'),
                    keyboardType: TextInputType.number,
                    initialValue: (reminder.remainder / 100.0).toStringAsFixed(2),
                    onChanged: (String input) => reminder.remainder = parseFloat(input) ?? 0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Frist', suffixText: 'Tage'),
                    keyboardType: TextInputType.number,
                    initialValue: (vendor != null
                            ? vendor.reminderDeadline
                            : bill.vendor.reminderDeadline ?? 14)
                        .toString(),
                    onChanged: (String input) =>
                        reminder.deadline = DateTime.now().add(Duration(days: int.parse(input))),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mahnungstitel'),
                    initialValue: reminder.title,
                    onChanged: (String input) => reminder.title = input,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(labelText: 'Mahnungstext'),
                    maxLines: 3,
                    initialValue: reminder.text,
                    onChanged: (String input) => reminder.text = input,
                  ),
                ],
              )),
        ],
      ),
    );
    if (result == null) return;
    _onGenerateReminder(result);
  }
}
