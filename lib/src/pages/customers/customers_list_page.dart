import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import 'customer_page.dart';

class CustomersListPage extends StatefulWidget {
  CustomersListPage({Key key}) : super(key: key);

  @override
  _CustomersListPageState createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> with WidgetsBindingObserver {
  CustomerRepository repo;
  List<Customer> customers = [];

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
            : Text('Kundenliste'),
        actions: <Widget>[
          if (!searchEnabled) ...[
            IconButton(
              tooltip: 'Neuen Kunden hinzufügen',
              icon: Icon(Icons.add),
              onPressed: onPushUserAddpage,
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
        child: (busy)
            ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
            : ListView(
                semanticChildCount: customers.length,
                children: <Widget>[
                  ...List.from(
                    customers.map<ListTile>((Customer c) => ListTile(
                          title: Text((c.company == null || c.company.isEmpty)
                              ? '${c.name} ${c.surname}'
                              : '${c.company} ${c.organizationUnit ?? ''}'),
                          subtitle: Text('${c.address}, ${c.zipCode} ${c.city}'),
                          onTap: () => onPushCustomerPage(context, c.id),
                        )),
                  )
                ],
              ),
        onRefresh: onGetCustomers,
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
    repo = CustomerRepository(InheritedDatabase.of(context).provider);
    await repo.setUp();
    await onGetCustomers();
  }

  Future<void> onGetCustomers() async {
    if (mounted) setState(() => busy = true);
    customers = await repo.select();
    _sortCustomers();
    if (mounted) setState(() => busy = false);
  }

  void _sortCustomers() {
    customers
        .sort((Customer a, Customer b) => (a.company ?? a.name).compareTo(b.company ?? b.name));
  }

  Future<void> onPushCustomerPage(BuildContext context, int id) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (BuildContext context) => CustomerPage(id: id)),
    );
    if (updated) {
      await onGetCustomers();
    }
  }

  Future<void> onPushUserAddpage() async {
    final updated = await Navigator.push<bool>(
        context, MaterialPageRoute<bool>(builder: (BuildContext context) => CustomerPage()));
    if (updated) {
      await onGetCustomers();
    }
  }

  Future<void> onSearchChanged(String value) async {
    customers = await repo.select(searchQuery: value);
    _sortCustomers();
    if (mounted) setState(() => customers);
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
      await onGetCustomers();
    }
  }
}
