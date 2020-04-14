import 'package:flutter/material.dart';

import '../models/draft.dart';
import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/bill_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/draft_repository.dart';
import '../repositories/vendor_repository.dart';
import 'draft_creator.dart';
import 'pdf_generator.dart';

class DraftsListPage extends StatefulWidget {
  @override
  _DraftsListPageState createState() => _DraftsListPageState();
}

class _DraftsListPageState extends State<DraftsListPage> {
  DraftRepository<MySqlProvider> draftRepo;
  BillRepository<MySqlProvider> billRepo;
  CustomerRepository<MySqlProvider> customerRepo;
  VendorRepository<MySqlProvider> vendorRepo;

  PdfGenerator pdfGen;

  List<Draft> drafts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entwürfe'),
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
          children: [
            ...drafts.reversed.map((Draft d) => ListTile(
                  title: Text('Entwurf ${d.id}'),
                  trailing: IconButton(
                      icon: Icon(Icons.picture_as_pdf), onPressed: () => onCreateBill(d.id)),
                  onTap: () => onPushDraftCreator(draft: d),
                )),
          ],
        ),
        onRefresh: () async => await onGetDrafts(),
      ),
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

  Future<void> onGetDrafts() async {
    drafts = await draftRepo.select();
    setState(() => drafts);
    return;
  }

  Future<void> onPushDraftCreator({Draft draft}) async {
    final updated = await Navigator.push<bool>(context,
        MaterialPageRoute<bool>(builder: (BuildContext context) => DraftCreatorPage(draft: draft)));
    if (updated) {
      await onGetDrafts();
    }
  }
}
