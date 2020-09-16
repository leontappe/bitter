import 'dart:io';
import 'dart:typed_data';

import 'package:bitter/src/models/reminder.dart';
import 'package:bitter/src/pdf/reminder_generator.dart';
import 'package:bitter/src/repositories/vendor_repository.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/bill.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../util.dart';
import '../../widgets/customer_card.dart';
import '../../widgets/items_card.dart';
import '../../widgets/vendor_card.dart';
import 'save_bill_button.dart';

class BillPage extends StatefulWidget {
  final int id;

  BillPage({this.id});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BillRepository repo;
  VendorRepository<DatabaseProvider> vendorRepo;

  Bill bill;

  Vendor vendor;

  bool dirty = false;

  @override
  Widget build(BuildContext context) {
    return (bill != null)
        ? Scaffold(
            appBar: AppBar(
              leading: Builder(
                  builder: (BuildContext context) => IconButton(
                        tooltip: 'Zurück',
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () => onPopRoute(context),
                      )),
              title: Text(bill.billNr),
              actions: [
                IconButton(icon: Icon(Icons.save), onPressed: onSaveBill),
                SaveBillButton(bill: bill),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(bill.billNr, style: Theme.of(context).textTheme.headline6),
                    subtitle:
                        Text('Erstellt am ${bill.created.toLocal().toString().split('.').first}'),
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
                          Text(
                              'Lieferdatum/Leistungsdatum: ${bill.serviceDate.day}.${bill.serviceDate.month}.${bill.serviceDate.year}'),
                        if (bill != null)
                          Text(
                              'Zahlungsziel: ${bill.dueDate.day}.${bill.dueDate.month}.${bill.dueDate.year}'),
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
                                  child: InkWell(
                                    onTap: () => _onGenerateReminder(r, skipSaving: true),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('${r.iteration.index + 1}. Mahnung',
                                              style: Theme.of(context).textTheme.headline5),
                                          Text('Frist: ${formatDate(r.deadline)}'),
                                          Text('Mahngebühr: ${r.fee.toStringAsFixed(2)}€'),
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
                        title: RaisedButton(
                      child: Text(
                          '${(bill.reminders.isNotEmpty) ? bill.reminders.last.iteration.index + 2 : '1'}. Mahnung erstellen'),
                      onPressed: () => _onShowReminderDialog(iterationFromInt(
                          (bill.reminders.isNotEmpty)
                              ? bill.reminders.last.iteration.index + 1
                              : 0)),
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
                    title: Text('Verkäufer', style: Theme.of(context).textTheme.headline6),
                    subtitle: VendorCard(vendor: bill.vendor),
                  ),
                  ListTile(
                    title: Text('Kunde', style: Theme.of(context).textTheme.headline6),
                    subtitle: CustomerCard(customer: bill.customer),
                  ),
                  ListTile(
                    title: Text('Artikel', style: Theme.of(context).textTheme.headline6),
                    subtitle: ItemsCard(items: bill.items, sum: bill.sum),
                  ),
                ],
              ),
            ),
          )
        : Container(width: 0.0, height: 0.0);
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = BillRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);

    await vendorRepo.setUp();

    bill = await repo.selectSingle(widget.id);
    vendor = await vendorRepo.selectSingle(bill.vendor.id);

    setState(() => bill);
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
            Scaffold.of(context).showSnackBar(const SnackBar(
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
      Navigator.pop<bool>(context, false);
    }
  }

  Future<bool> onSaveBill() async {
    if (_formKey.currentState.validate()) {
      await repo.update(bill);
      dirty = false;
      return true;
    }
    return false;
  }

  void _onShowReminderDialog(ReminderIteration iteration) async {
    final reminder = Reminder(
      iteration: iteration,
      text: vendor.reminderTexts[iteration],
      fee: vendor.reminderFee,
      deadline: DateTime.now().add(Duration(days: vendor.reminderDeadline)),
    );

    final result = await showDialog<Reminder>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        contentPadding: EdgeInsets.all(16.0),
        title: Text('${iteration.index + 1}. Mahnung erstellen'),
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Mahngebühr', suffixText: '€'),
            keyboardType: TextInputType.number,
            initialValue: reminder.fee.toString(),
            onChanged: (String input) => reminder.fee = int.parse(input),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Frist', suffixText: 'Tage'),
            keyboardType: TextInputType.number,
            initialValue: vendor.reminderDeadline.toString(),
            onChanged: (String input) =>
                reminder.deadline = DateTime.now().add(Duration(days: int.parse(input))),
          ),
          TextFormField(
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(labelText: 'Mahnungstext'),
            maxLines: 3,
            initialValue: reminder.text,
            onChanged: (String input) => reminder.text = input,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              MaterialButton(
                  onPressed: () => Navigator.of(context).pop(null), child: Text('Abbrechen')),
              MaterialButton(
                  onPressed: () => Navigator.of(context).pop(reminder),
                  child: Text('Mahnung erstellen')),
            ],
          )
        ],
      ),
    );
    if (result == null) return;
    _onGenerateReminder(result);
  }

  void _onGenerateReminder(Reminder reminder, {bool skipSaving = false}) async {
    if (!skipSaving) {
      setState(() => bill.reminders.add(reminder));
      dirty = true;
    }

    final pdfData = await ReminderGenerator().getBytesFromBill(
      bill,
      await vendorRepo.selectSingle(bill.vendor.id),
      reminder,
      leftHeader: bill.vendor.headerImageLeft as Uint8List,
      centerHeader: bill.vendor.headerImageCenter as Uint8List,
      rightHeader: bill.vendor.headerImageRight as Uint8List,
    );

    String downloadsPath;
    if (Platform.isWindows) {
      downloadsPath = (await getApplicationDocumentsDirectory()).path;
    } else {
      downloadsPath = (await getDownloadsDirectory()).path;
    }
    final file =
        File('${downloadsPath}/bitter/Mahnung${reminder.iteration.index + 1}_${bill.billNr}.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(pdfData);
  }
}
