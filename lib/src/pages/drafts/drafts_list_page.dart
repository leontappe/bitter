import 'package:flutter/material.dart';

import '../../models/draft.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../widgets/database_error_watcher.dart';
import 'draft_creator.dart';
import 'draft_popup_menu.dart';

class DraftsListPage extends StatefulWidget {
  @override
  _DraftsListPageState createState() => _DraftsListPageState();
}

class _DraftsListPageState extends State<DraftsListPage> {
  DraftRepository draftRepo;
  CustomerRepository customerRepo;
  VendorRepository vendorRepo;
  SettingsRepository settings;

  List<Draft> drafts = [];
  List<Customer> customers = [];
  List<Vendor> vendors = [];

  String searchQuery;
  List<Vendor> filterVendors = [];
  int filterVendor;

  bool searchEnabled = false;

  bool busy = false;

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
              value: filterVendor ?? -1,
              dropdownColor: Colors.grey[800],
              iconEnabledColor: Colors.white70,
              style:
                  TextStyle(color: Colors.white, decorationColor: Colors.white70, fontSize: 14.0),
              hint: Text('Nach Verkäufer filtern', style: TextStyle(color: Colors.white)),
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem(child: Text('Filter zurücksetzen'), value: -1),
                ...filterVendors
                    .map((Vendor v) => DropdownMenuItem(value: v.id, child: Text(v.name))),
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
        child: DatabaseErrorWatcher(
          child: (busy)
              ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
              : ListView(
                  children: [
                    ...drafts.reversed.map((Draft d) => ListTile(
                          title: Text('Entwurf ${d.id}'),
                          subtitle: Text((vendors.isNotEmpty && customers.isNotEmpty)
                              ? 'Bearbeiter*in: ${d.editor}, ${vendors.where((Vendor v) => v.id == d.vendor).isEmpty ? '' : vendors.singleWhere((Vendor v) => v.id == d.vendor).name} - Kunde*in: ${customers.where((Customer c) => c.id == d.customer).isEmpty ? '' : customers.singleWhere((Customer c) => c.id == d.customer).name} ${customers.where((Customer c) => c.id == d.customer).isEmpty ? '' : customers.singleWhere((Customer c) => c.id == d.customer).surname}'
                              : 'Bearbeiter*in: ${d.editor}'),
                          trailing: DraftPopupMenu(
                              id: d.id,
                              onStarted: () => setState(() => busy = true),
                              onCompleted: (bool changed, bool redirect) {
                                setState(() => busy = false);
                                if (changed) {
                                  if (redirect) {
                                    Navigator.pushNamed(context, '/bills');
                                    return;
                                  }
                                  onGetDrafts();
                                }
                              }),
                          onTap: () => onPushDraftCreator(draft: d),
                        )),
                  ],
                ),
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
    if (mounted) setState(() => busy = true);
    draftRepo = DraftRepository(InheritedDatabase.of(context));
    vendorRepo = VendorRepository(InheritedDatabase.of(context));
    customerRepo = CustomerRepository(InheritedDatabase.of(context));
    settings = SettingsRepository();
    await draftRepo.setUp();
    await vendorRepo.setUp();
    await customerRepo.setUp();
    await settings.setUp();

    customers = await customerRepo.select();
    vendors = await vendorRepo.select();

    final filter = await settings.select<int>('drafts_filter');
    if (drafts.where((Draft d) => d.vendor == filter).isEmpty) {
      filterVendor = null;
    } else {
      filterVendor = filter;
    }

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
    if (mounted) setState(() => busy = true);
    drafts = await draftRepo.select(searchQuery: searchQuery, vendorFilter: filterVendor);

    if (filterVendor == null) {
      for (var draft in drafts) {
        if (filterVendors.where((Vendor v) => v.id == draft.vendor).isEmpty) {
          try {
            filterVendors.add(await vendorRepo.selectSingle(draft.vendor));
          } catch (e) {
            print(e);
          }
        }
      }
    }

    if (mounted) setState(() => busy = false);
  }

  Future<void> onPushDraftCreator({Draft draft}) async {
    final updated = await Navigator.push<bool>(context,
        MaterialPageRoute<bool>(builder: (BuildContext context) => DraftCreatorPage(draft: draft)));
    if (updated) await onGetDrafts();
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
