import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../pdf/pdf_generator.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/vendor_repository.dart';

class DraftPopupMenu extends StatefulWidget {
  final int id;

  /// first bool returns if something changed, second one if the page should redirect to bills
  final Function(bool, bool) onCompleted;

  const DraftPopupMenu({Key key, this.id, this.onCompleted}) : super(key: key);

  @override
  _DraftPopupMenuState createState() => _DraftPopupMenuState();
}

enum DraftPopupSelection {
  createBill,
  delete,
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
          value: DraftPopupSelection.createBill,
          child: Text('Rechnung exportieren'),
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
    repo = DraftRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    billRepo = BillRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);

    await billRepo.setUp();

    draft = await repo.selectSingle(widget.id);
  }

  @override
  void initState() {
    super.initState();
    pdfGen = PdfGenerator();
  }

  Future<void> onSelected(DraftPopupSelection value) async {
    switch (value) {
      case DraftPopupSelection.createBill:
        final billResult = await _createBill(widget.id);
        (widget.onCompleted != null) ? widget.onCompleted(billResult, billResult) : null;
        break;
      case DraftPopupSelection.delete:
        final result = await _deleteDraft();
        (widget.onCompleted != null) ? widget.onCompleted(result, false) : null;
        break;
      default:
        (widget.onCompleted != null) ? widget.onCompleted(false, false) : null;
        break;
    }
  }

  Future<bool> _createBill(int id) async {
    draft = await repo.selectSingle(id);

    if (draft.items.isEmpty) {
      Scaffold.of(context).showSnackBar(const SnackBar(
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

    final billNrString = '${vendor.billPrefix}-$billNr';

    final doc = await pdfGen.getBytesFromBill(
      billNrString,
      draft,
      customer,
      vendor,
      rightHeader:
          (vendor.headerImageRight != null) ? Uint8List.fromList(vendor.headerImageRight) : null,
      centerHeader:
          (vendor.headerImageCenter != null) ? Uint8List.fromList(vendor.headerImageCenter) : null,
      leftHeader:
          (vendor.headerImageLeft != null) ? Uint8List.fromList(vendor.headerImageLeft) : null,
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
      Scaffold.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Die Rechnung wurde nicht abgespeichert, bitte starte die Anwendung neu und versuche es noch mal'),
        duration: Duration(seconds: 3),
      ));
      return false;
    }
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
