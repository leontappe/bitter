import 'package:flutter/material.dart';

import '../drafts/draft_popup_menu.dart';
import '../models/draft.dart';
import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/draft_repository.dart';
import '../repositories/vendor_repository.dart';
import 'draft_creator.dart';

class DraftsListPage extends StatefulWidget {
  @override
  _DraftsListPageState createState() => _DraftsListPageState();
}

class _DraftsListPageState extends State<DraftsListPage> {
  DraftRepository<MySqlProvider> draftRepo;
  CustomerRepository<MySqlProvider> customerRepo;
  VendorRepository<MySqlProvider> vendorRepo;

  List<Draft> drafts = [];
  List<Customer> customers = [];
  List<Vendor> vendors = [];

  bool searchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !searchEnabled,
        title: searchEnabled
            ? TextField(
                autofocus: true,
                maxLines: 1,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    hintText: 'Suchbegriff',
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: Colors.white), onPressed: onToggleSearch)),
                onChanged: onSearchChanged,
              )
            : Text('Entwürfe'),
        actions: <Widget>[
          if (!searchEnabled) ...[
            IconButton(
              tooltip: 'Neue Rechnung erstellen',
              icon: Icon(Icons.note_add),
              onPressed: onPushDraftCreator,
            ),
            IconButton(icon: Icon(Icons.search), onPressed: onToggleSearch),
          ],
        ],
      ),
      body: RefreshIndicator(
        child: ListView(
          children: [
            ...drafts.reversed.map((Draft d) => ListTile(
                  title: Text('Entwurf ${d.id}'),
                  subtitle: Text((vendors.isNotEmpty && customers.isNotEmpty)
                      ? 'Bearbeiter*in: ${d.editor}, ${vendors.where((Vendor v) => v.id == d.vendor).isEmpty ? '' : vendors.singleWhere((Vendor v) => v.id == d.vendor).name} - Kunde*in: ${customers.where((Customer c) => c.id == d.customer).isEmpty ? '' : customers.singleWhere((Customer c) => c.id == d.customer).name} ${customers.where((Customer c) => c.id == d.customer).isEmpty ? '' : customers.singleWhere((Customer c) => c.id == d.customer).surname}'
                      : 'Bearbeiter*in: ${d.editor}'),
                  trailing: DraftPopupMenu(
                    id: d.id,
                    onCompleted: (bool changed) => changed ? onGetDrafts() : null,
                  ),
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
    vendorRepo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    await draftRepo.setUp();
    await vendorRepo.setUp();
    await customerRepo.setUp();

    await onGetDrafts();

    customers = await customerRepo.select();
    vendors = await vendorRepo.select();
    setState(() => vendors);
  }

  Future<void> onGetDrafts() async {
    drafts = await draftRepo.select();
    setState(() => drafts);
  }

  Future<void> onPushDraftCreator({Draft draft}) async {
    final updated = await Navigator.push<bool>(context,
        MaterialPageRoute<bool>(builder: (BuildContext context) => DraftCreatorPage(draft: draft)));
    if (updated) {
      await onGetDrafts();
    }
  }

  Future<void> onSearchChanged(String value) async {
    drafts = await draftRepo.select(searchQuery: value, customers: customers, vendors: vendors);
    setState(() => drafts);
  }

  void onToggleSearch() async {
    setState(() {
      if (searchEnabled) {
        searchEnabled = false;
      } else {
        searchEnabled = true;
      }
    });

    if (!searchEnabled) {
      await onGetDrafts();
    }
  }
}
