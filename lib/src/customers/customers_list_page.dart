import 'package:flutter/material.dart';

import 'customer_adding.dart';
import 'customer_page.dart';
import '../providers/customer_provider.dart';

class CustomersListPage extends StatefulWidget {
  CustomersListPage({Key key}) : super(key: key);

  @override
  _CustomersListPageState createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> {
  CustomerProvider db;
  List<Customer> customers = [];

  bool searchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () => Navigator.push<MaterialPageRoute>(context,
                    MaterialPageRoute(builder: (BuildContext context) => CustomerAddingPage()))),
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
                    title: Text((c.company == null)
                        ? '${c.name} ${c.surname}'
                        : '${c.company} ${c.organizationUnit}'),
                    subtitle: Text('${c.address}, ${c.zipCode} ${c.city}'),
                    onTap: () => Navigator.push<MaterialPageRoute>(context,
                        MaterialPageRoute(builder: (BuildContext context) => CustomerPage(c.id))),
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
    db = CustomerProvider();
    await db.open('bitter5.db');
    //_insertTestData();
    await onGetCustomers();
  }

  @override
  void initState() {
    super.initState();
    initDb();
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

  Future<void> onGetCustomers() async {
    customers = await db.getCustomers();
    setState(() {
      return customers;
    });
  }

  Future<void> onSearchChanged(String value) async {
    customers = await db.getCustomers(searchQuery: value);
    setState(() {
      return customers;
    });
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
