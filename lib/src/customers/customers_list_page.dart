import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/pgsql_customer_provider.dart';
import 'customer_adding.dart';
import 'customer_page.dart';

class CustomersListPage extends StatefulWidget {
  CustomersListPage({Key key}) : super(key: key);

  @override
  _CustomersListPageState createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> with WidgetsBindingObserver {
  PgSQLCustomerProvider db;
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
                        icon: Icon(Icons.clear, color: Colors.white), onPressed: onToggleSearch)),
                onChanged: onSearchChanged,
              )
            : Text('Kundenliste'),
        actions: <Widget>[
          if (!searchEnabled) ...[
            IconButton(icon: Icon(Icons.add), onPressed: onPushUserAddpage),
            IconButton(icon: Icon(Icons.search), onPressed: onToggleSearch),
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
      floatingActionButton:
          FloatingActionButton(onPressed: onGetCustomers, child: Icon(Icons.refresh)),
    );
  }

  Future<void> initDb() async {
    db = PgSQLCustomerProvider();
    await db.open('bitter', host: '127.0.0.1', port: 5432, user: 'ltappe');
    //_insertTestData();
    await onGetCustomers();
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> onGetCustomers() async {
    customers = await db.select();
    setState(() {
      return customers;
    });
  }

  Future<void> onPushCustomerPage(BuildContext context, int id) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (BuildContext context) => CustomerPage(id)),
    );
    if (updated) {
      await onGetCustomers();
    }
  }

  Future<void> onPushUserAddpage() async {
    final updated = await Navigator.push<bool>(
        context, MaterialPageRoute<bool>(builder: (BuildContext context) => CustomerAddingPage()));
    if (updated) {
      await onGetCustomers();
    }
  }

  Future<void> onSearchChanged(String value) async {
    customers = await db.select(searchQuery: value);
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

  Future<void> _insertTestData() async {
    await db.insert(
      Customer(
          name: 'Leon',
          surname: 'Tappe',
          gender: Gender.male,
          address: 'Warburger Straße 100',
          zipCode: 33098,
          city: 'Paderborn',
          email: 'ltappe@mail.upb.de'),
    );

    await db.insert(
      Customer(
          company: 'AStA Paderborn',
          organizationUnit: 'IT',
          name: 'Leon',
          surname: 'Tappe',
          gender: Gender.male,
          address: 'Warburger Straße 100',
          zipCode: 33098,
          city: 'Paderborn',
          email: 'ltappe@asta.upb.de'),
    );
  }
}
