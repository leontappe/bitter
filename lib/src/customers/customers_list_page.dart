import '../providers/mysql_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/inherited_database.dart';
import '../repositories/customer_repository.dart';
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
        child: ListView(
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
    repo = CustomerRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    await repo.setUp();
    await onGetCustomers();
  }

  Future<void> onGetCustomers() async {
    customers = await repo.select();
    setState(() {
      return customers;
    });
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
    setState(() {
      return customers;
    });
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
