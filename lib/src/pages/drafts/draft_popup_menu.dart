import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

import '../../pdf/pdf_generator.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../util/format_util.dart';
import '../../util/ui_util.dart';
import '../../widgets/option_dialog.dart';

class BillDialogResult {
  bool submit;
  String letter;
  String title;
  bool showDates;

  BillDialogResult({
    this.submit = false,
    this.letter,
    this.title,
    this.showDates = true,
  });
}

class DraftPopupMenu extends StatefulWidget {
  final int id;

  /// first bool returns if something changed, second one if the page should redirect to bills
  final Function(bool, bool) onCompleted;
  final Function() onStarted;

  const DraftPopupMenu({Key key, this.id, this.onCompleted, this.onStarted}) : super(key: key);

  @override
  _DraftPopupMenuState createState() => _DraftPopupMenuState();
}

enum DraftPopupSelection {
  createBill,
  delete,
  createPreview,
}

class _DraftPopupMenuState extends State<DraftPopupMenu> {
  DraftRepository repo;
  CustomerRepository customerRepo;
  VendorRepository vendorRepo;
  BillRepository billRepo;

  PdfGenerator pdfGen;

  Draft draft;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DraftPopupSelection>(
      tooltip: 'Menü zeigen',
      onSelected: onSelected,
      onCanceled: () => (widget.onCompleted != null) ? widget.onCompleted(false, false) : null,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<DraftPopupSelection>>[
        const PopupMenuItem<DraftPopupSelection>(
          value: DraftPopupSelection.createPreview,
          child: Text('Vorschau erstellen'),
        ),
        const PopupMenuItem<DraftPopupSelection>(
          value: DraftPopupSelection.createBill,
          child: Text('Rechnung erstellen'),
        ),
        const PopupMenuItem<DraftPopupSelection>(
          value: DraftPopupSelection.delete,
          child: Text('Entwurf löschen'),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = DraftRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));
    customerRepo = CustomerRepository(InheritedDatabase.of(context));
    billRepo = BillRepository(InheritedDatabase.of(context));

    await billRepo.setUp();

    draft = await repo.selectSingle(widget.id);
  }

  @override
  void initState() {
    super.initState();
    pdfGen = PdfGenerator();
  }

  Future<void> onSelected(DraftPopupSelection value) async {
    if (widget.onStarted != null) widget.onStarted;
    switch (value) {
      case DraftPopupSelection.createBill:
        final billResult = await _createBill(widget.id);
        (widget.onCompleted != null) ? widget.onCompleted(billResult, billResult) : null;
        break;
      case DraftPopupSelection.delete:
        final result = await _deleteDraft();
        (widget.onCompleted != null) ? widget.onCompleted(result, false) : null;
        break;
      case DraftPopupSelection.createPreview:
        await _createPreview(widget.id);
        (widget.onCompleted != null) ? widget.onCompleted(false, false) : null;
        break;
      default:
        (widget.onCompleted != null) ? widget.onCompleted(false, false) : null;
        break;
    }
  }

  Future<bool> _createBill(int id) async {
    draft = await repo.selectSingle(id);

    if (draft == null) return false;

    if (draft.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Dieser Entwurf enthält keine Artikel'), duration: Duration(seconds: 3)));
      return false;
    }

    final customer = await customerRepo.selectSingle(draft.customer);
    final vendor = await vendorRepo.selectSingle(draft.vendor);
    final bills = await billRepo.select();

    int billNr;
    final relatedBills = bills.where((Bill b) => b.billNr.split('-').first == vendor.billPrefix);
    if (relatedBills.isEmpty) {
      billNr = 1;
    } else {
      billNr = int.parse(relatedBills.last.billNr.split('-').last) + 1;
    }

    // TODO: show dialog and stuff
    final dialogResult = await showDialog<BillDialogResult>(
        context: context,
        builder: (BuildContext context) {
          var result = BillDialogResult(title: 'Rechnung');
          return OptionDialog(
            titleText: 'Rechnung erstellen',
            checkboxText: 'Liefer- und Leistungsdatum anzeigen',
            checked: result.showDates,
            onChecked: (bool input) => result.showDates = input,
            actions: [
              MaterialButton(
                onPressed: () {
                  result.submit = false;
                  Navigator.pop(context, result);
                },
                child: Text('Abbrechen'),
              ),
              MaterialButton(
                onPressed: () {
                  result.submit = true;
                  Navigator.pop(context, result);
                },
                child: Text('Erstellen'),
              ),
            ],
            children: [
              Text('Der Entwurf wird nach dem Erstellen der Rechnung automatisch gelöscht.'),
              TextFormField(
                decoration: InputDecoration(labelText: 'Titel*'),
                maxLines: 1,
                controller: TextEditingController(text: 'Rechnung'),
                onChanged: (String input) => result.title = input,
                validator: (String input) => input.isEmpty ? 'Titel kann nicht leer sein' : null,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Anschreiben',
                  hintText: defaultLetter,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                maxLines: null,
                controller: TextEditingController(text: result.letter),
                onChanged: (String input) => result.letter = input,
              ),
            ],
          );
        });

    if (dialogResult == null || !dialogResult.submit) return false;

    final billNrString = '${vendor.billPrefix}-$billNr';

    final doc = await pdfGen.getBytesFromBill(
      draft,
      customer,
      vendor,
      billNr: billNrString,
      rightHeader:
          (vendor.headerImageRight != null) ? Uint8List.fromList(vendor.headerImageRight) : null,
      centerHeader:
          (vendor.headerImageCenter != null) ? Uint8List.fromList(vendor.headerImageCenter) : null,
      leftHeader:
          (vendor.headerImageLeft != null) ? Uint8List.fromList(vendor.headerImageLeft) : null,
      title: dialogResult.title,
      letter: dialogResult.letter,
      showDates: dialogResult.showDates,
    );

    await billRepo.insert(Bill(
      billNr: billNrString,
      file: doc,
      sum: draft.sum,
      editor: draft.editor,
      vendor: vendor,
      customer: customer,
      items: draft.items,
      created: DateTime.now(),
      serviceDate: draft.serviceDate ?? DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: draft.dueDays)),
      userMessage: draft.userMessage,
      comment: draft.comment,
    ));

    if ((await billRepo.select()).length > bills.length) {
      await repo.delete(draft.id);
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Die Rechnung wurde nicht abgespeichert, bitte starte die Anwendung neu und versuche es noch mal'),
        duration: Duration(seconds: 3),
      ));
      return false;
    }
  }

  Future<bool> _createPreview(int id) async {
    draft = await repo.selectSingle(id);

    if (draft == null) return false;

    if (draft.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Dieser Entwurf enthält keine Artikel'), duration: Duration(seconds: 3)));
      return false;
    }

    final dialogResult = await showDialog<BillDialogResult>(
        context: context,
        builder: (BuildContext context) {
          var result = BillDialogResult(title: 'Vorschau');
          return OptionDialog(
            titleText: 'Vorschau erstellen',
            checkboxText: 'Liefer- und Leistungsdatum anzeigen',
            checked: result.showDates,
            onChecked: (bool input) => result.showDates = input,
            actions: [
              MaterialButton(
                onPressed: () {
                  result.submit = false;
                  Navigator.pop(context, result);
                },
                child: Text('Abbrechen'),
              ),
              MaterialButton(
                onPressed: () {
                  result.submit = true;
                  Navigator.pop(context, result);
                },
                child: Text('Erstellen'),
              ),
            ],
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Titel*'),
                maxLines: 1,
                controller: TextEditingController(text: 'Vorschau'),
                onChanged: (String input) => result.title = input,
                validator: (String input) => input.isEmpty ? 'Titel kann nicht leer sein' : null,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Anschreiben',
                  hintText: defaultLetter,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                maxLines: null,
                controller: TextEditingController(text: result.letter),
                onChanged: (String input) => result.letter = input,
              ),
            ],
          );
        });

    if (dialogResult == null || !dialogResult.submit) return false;

    final customer = await customerRepo.selectSingle(draft.customer);
    final vendor = await vendorRepo.selectSingle(draft.vendor);

    final doc = await pdfGen.getBytesFromBill(
      draft,
      customer,
      vendor,
      title: dialogResult.title,
      letter: dialogResult.letter,
      rightHeader:
          (vendor.headerImageRight != null) ? Uint8List.fromList(vendor.headerImageRight) : null,
      centerHeader:
          (vendor.headerImageCenter != null) ? Uint8List.fromList(vendor.headerImageCenter) : null,
      leftHeader:
          (vendor.headerImageLeft != null) ? Uint8List.fromList(vendor.headerImageLeft) : null,
      showDates: dialogResult.showDates,
    );

    await onSaveBill(context, '${formatFilenameDate(DateTime.now())}_${dialogResult.title}', doc);

    return true;
  }

  Future<bool> _deleteDraft() async {
    final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Möchtest du diesen Entwurf wirklich löschen?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Nein')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Ja')),
              ],
            ));
    if (result ?? false) await repo.delete(widget.id);
    return result ?? false;
  }
}
