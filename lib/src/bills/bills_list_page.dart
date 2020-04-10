import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/draft.dart';
import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/bill_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/draft_repository.dart';
import '../repositories/vendor_repository.dart';
import 'draft_creator.dart';
import 'pdf_generator.dart';

class BillsListPage extends StatefulWidget {
  @override
  _BillsListPageState createState() => _BillsListPageState();
}

class _BillsListPageState extends State<BillsListPage> {
  DraftRepository<MySqlProvider> draftRepo;
  BillRepository<MySqlProvider> billRepo;
  CustomerRepository<MySqlProvider> customerRepo;
  VendorRepository<MySqlProvider> vendorRepo;

  PdfGenerator pdfGen;

  List<Draft> drafts = [];
  List<Bill> bills = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechnungen'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Neue Rechnung erstellen',
            icon: Icon(Icons.note_add),
            onPressed: onPushDraftCreator,
          )
        ],
      ),
      body: RefreshIndicator(
          child: ListView(
            semanticChildCount: 4,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(title: Text('Entwürfe', style: Theme.of(context).textTheme.headline6)),
                  Divider(height: 0.0),
                  ...drafts.map((Draft d) => ListTile(
                        title: Text('Entwurf ${d.id}'),
                        trailing: IconButton(
                            icon: Icon(Icons.picture_as_pdf), onPressed: () => onCreateBill(d.id)),
                      )),
                ],
              ),
              Divider(height: 4.0),
              Divider(height: 4.0),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(title: Text('Rechnungen', style: Theme.of(context).textTheme.headline6)),
                  Divider(height: 0.0),
                  ...bills.map((Bill b) => ListTile(
                        title: Text(b.billNr),
                        trailing: IconButton(
                            icon: Icon(Icons.file_download), onPressed: () => onSaveBill(b)),
                      ))
                ],
              )
            ],
          ),
          onRefresh: () async {
            await onGetDrafts();
            await onGetBills();
          }),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    draftRepo = DraftRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    billRepo = BillRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    await draftRepo.setUp();
    await billRepo.setUp();
    await vendorRepo.setUp();

    await onGetDrafts();
    await onGetBills();
  }

  @override
  void initState() {
    super.initState();
    pdfGen = PdfGenerator();
  }

  void onCreateBill(int id) async {
    final bill = drafts.singleWhere((Draft d) => d.id == id);
    final customer = await customerRepo.selectSingle(bill.customer);
    final vendor = await vendorRepo.selectSingle(bill.vendor);

    final bills = await billRepo.select();
    int billNr;

    if (bills.isEmpty) {
      billNr = 1;
    } else {
      billNr = int.parse(bills.last.billNr.substring(2)) + 1;
    }

    final billNrString = '${vendor.billPrefix}$billNr';

    final doc = pdfGen.getBytesFromBill(billNrString, bill, customer, vendor);

    bills.add(await billRepo
        .insert(Bill(billNr: billNrString, file: doc, created: DateTime.now().toUtc())));

    setState(() => bills);
  }

  Future<void> onGetBills() async {
    bills = await billRepo.select();
    setState(() => bills);
    return;
  }

  Future<void> onGetDrafts() async {
    drafts = await draftRepo.select();
    setState(() => drafts);
    return;
  }

  Future<void> onPushDraftCreator() async {
    final updated = await Navigator.push<bool>(
        context, MaterialPageRoute<bool>(builder: (BuildContext context) => DraftCreatorPage()));
    if (updated) {
      await onGetDrafts();
    }
  }

  Future<void> onSaveBill(Bill bill) async {
    Directory downloadsPath;
    if (Platform.isWindows) {
      downloadsPath = (await getApplicationDocumentsDirectory());
    } else {
      downloadsPath = await getDownloadsDirectory();
    }
    final file = File('${downloadsPath.path}/bitter/${bill.billNr}.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(bill.file);
  }
}
