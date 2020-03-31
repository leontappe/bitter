import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../providers/inherited_database.dart';
import '../../providers/mysql_provider.dart';
import '../../repositories/vendor_repository.dart';
import 'vendor_adding.dart';
import 'vendor_page.dart';

class VendorsPage extends StatefulWidget {
  @override
  _VendorsPageState createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  VendorRepository repo;

  List<Vendor> vendors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verkäufer'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: onPushVendorAddPage),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onGetVendors,
        child: ListView(
          semanticChildCount: vendors.length,
          children: <Widget>[
            ...vendors.map((Vendor v) =>
                ListTile(title: Text(v.name), onTap: () => onPushVendorPage(context, v.id))),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: onGetVendors, child: Icon(Icons.refresh)),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = VendorRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    await repo.setUp();
    await onGetVendors();
  }

  Future<void> onGetVendors() async {
    vendors = await repo.select();
    setState(() => vendors);
  }

  void onPushVendorAddPage() async {
    final updated = await Navigator.push<bool>(
        context, MaterialPageRoute<bool>(builder: (BuildContext context) => VendorAddingPage()));
    if (updated) {
      await onGetVendors();
    }
  }

  Future<void> onPushVendorPage(BuildContext context, int id) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (BuildContext context) => VendorPage(id)),
    );
    if (updated) {
      await onGetVendors();
    }
  }
}
