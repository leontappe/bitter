import 'package:flutter/material.dart';

import '../../models/draft.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';
import 'draft_popup_menu.dart';
import 'draft_creator.dart';

class DraftsListPage extends StatefulWidget {
  @override
  _DraftsListPageState createState() => _DraftsListPageState();
}

class _DraftsListPageState extends State<DraftsListPage> {
  DraftRepository<DatabaseProvider> draftRepo;
  CustomerRepository<DatabaseProvider> customerRepo;
  VendorRepository<DatabaseProvider> vendorRepo;
  SettingsRepository settings;

  List<Draft> drafts = [];
  List<Customer> customers = [];
  List<Vendor> vendors = [];

  String searchQuery;
  List<Vendor> filterVendors = [];
  int filterVendor;

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
                      tooltip: 'Suchleiste deaktivieren',
                      icon: Icon(Icons.clear, color: Colors.white),
                      onPressed: onToggleSearch,
                    )),
                onChanged: onSearchChanged,
              )
            : Text('Entwürfe'),
        actions: <Widget>[
          if (!searchEnabled) ...[
            DropdownButton<int>(
              value: filterVendor,
              dropdownColor: Colors.grey[800],
              iconEnabledColor: Colors.white70,
              style:
                  TextStyle(color: Colors.white, decorationColor: Colors.white70, fontSize: 14.0),
              hint: Text('Nach Verkäufer filtern', style: TextStyle(color: Colors.white)),
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem(child: Text('Filter zurücksetzen'), value: -1),
                ...filterVendors
                    .map((Vendor v) => DropdownMenuItem(value: v.id, child: Text(v.name)))
              ],
              onChanged: onFilter,
            ),
            IconButton(
              tooltip: 'Neue Rechnung erstellen',
              icon: Icon(Icons.note_add),
              onPressed: onPushDraftCreator,
            ),
            IconButton(
              tooltip: 'Suchleiste aktivieren',
              icon: Icon(Icons.search),
              onPressed: onToggleSearch,
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        child: ListView(
          children: [
            ...drafts.map((Draft d) => ListTile(
                  title: Text('Entwurf ${d.id}'),
                  subtitle: Text((vendors.isNotEmpty && customers.isNotEmpty)
                      ? 'Bearbeiter*in: ${d.editor}, ${vendors.where((Vendor v) => v.id == d.vendor).isEmpty ? '' : vendors.singleWhere((Vendor v) => v.id == d.vendor).name} - Kunde*in: ${customers.where((Customer c) => c.id == d.customer).isEmpty ? '' : customers.singleWhere((Customer c) => c.id == d.customer).name} ${customers.where((Customer c) => c.id == d.customer).isEmpty ? '' : customers.singleWhere((Customer c) => c.id == d.customer).surname}'
                      : 'Bearbeiter*in: ${d.editor}'),
                  trailing: DraftPopupMenu(
                      id: d.id,
                      onCompleted: (bool changed) {
                        if (changed) {
                          onGetDrafts();
                          Navigator.pushNamed(context, '/bills');
                        }
                      }),
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
    draftRepo = DraftRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    vendorRepo = VendorRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    customerRepo = CustomerRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    settings = SettingsRepository();
    await draftRepo.setUp();
    await vendorRepo.setUp();
    await customerRepo.setUp();
    await settings.setUp();

    await onGetDrafts();

    customers = await customerRepo.select();
    vendors = await vendorRepo.select();

    filterVendor = await settings.select<int>('drafts_filter');
    await onGetDrafts();
  }

  Future<void> onFilter(int value) async {
    if (value >= 0) {
      filterVendor = value;
    } else {
      filterVendor = null;
    }
    await onGetDrafts();
    await settings.insert('drafts_filter', filterVendor);
  }

  Future<void> onGetDrafts() async {
    drafts = await draftRepo.select(searchQuery: searchQuery, vendorFilter: filterVendor);

    if (filterVendor == null) {
      for (var draft in drafts) {
        if (filterVendors.where((Vendor v) => v.id == draft.vendor).isEmpty) {
          filterVendors.add(await vendorRepo.selectSingle(draft.vendor));
        }
      }
    }

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
    searchQuery = value;
    await onGetDrafts();
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
      searchQuery = null;
      await onGetDrafts();
    }
  }
}