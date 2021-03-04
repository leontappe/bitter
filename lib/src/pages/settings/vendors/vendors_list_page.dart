import 'package:flutter/material.dart';

import '../../../models/vendor.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/inherited_database.dart';
import '../../../repositories/vendor_repository.dart';
import '../../../widgets/database_error_watcher.dart';
import 'vendor_page.dart';

class VendorsPage extends StatefulWidget {
  @override
  _VendorsPageState createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  VendorRepository repo;

  List<Vendor> vendors = [];

  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verkäufer'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Neuen Verkäufer hinzufügen',
            icon: Icon(Icons.add),
            onPressed: onPushVendorAddPage,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onGetVendors,
        child: DatabaseErrorWatcher(
          child: (busy)
              ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
              : ListView(
                  semanticChildCount: vendors.length,
                  children: <Widget>[
                    ...vendors.reversed.map((Vendor v) => ListTile(
                        title: Text(v.name), onTap: () => onPushVendorPage(context, v.id))),
                  ],
                ),
        ),
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
    repo = VendorRepository<DatabaseProvider>(InheritedDatabase.of(context));
    await repo.setUp();
    await onGetVendors();
  }

  Future<void> onGetVendors() async {
    if (mounted) setState(() => busy = true);
    vendors = await repo.select(short: true);
    if (mounted) setState(() => busy = false);
  }

  void onPushVendorAddPage() async {
    final updated = await Navigator.push<bool>(
        context, MaterialPageRoute<bool>(builder: (BuildContext context) => VendorPage()));
    if (updated) {
      await onGetVendors();
    }
  }

  Future<void> onPushVendorPage(BuildContext context, int id) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (BuildContext context) => VendorPage(id: id)),
    );
    if (updated) {
      await onGetVendors();
    }
  }
}
