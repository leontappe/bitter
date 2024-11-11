import 'package:flutter/material.dart';

import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../widgets/navigation_card.dart';
import '../../widgets/shortcuts/draft_shortcut.dart';
import '../drafts/draft_creator.dart';

class DraftsNavigationCard extends StatefulWidget {
  final int filter;

  DraftsNavigationCard({this.filter}) : super(key: Key(filter.toString()));

  @override
  _DraftsNavigationCardState createState() => _DraftsNavigationCardState();
}

class _DraftsNavigationCardState extends State<DraftsNavigationCard> {
  DraftRepository _draftRepo;
  CustomerRepository _customerRepo;
  VendorRepository _vendorRepo;

  List<Draft> _drafts = [];
  List<Vendor> _vendors;
  List<Customer> _customers;

  @override
  Widget build(BuildContext context) {
    return NavigationCard(
      context,
      '/drafts',
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text('Entwürfe',
                    style: Theme.of(context).textTheme.headline5, overflow: TextOverflow.ellipsis)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    tooltip: 'Neuen Entwurf erstellen',
                    icon: Icon(Icons.note_add, color: Colors.grey[700]),
                    onPressed: () async {
                      await Navigator.push<bool>(
                          context,
                          MaterialPageRoute<bool>(
                              builder: (BuildContext context) => DraftCreatorPage()));
                      await onRefresh();
                    }),
                IconButton(
                    tooltip: 'Aktualisieren',
                    icon: Icon(Icons.refresh, color: Colors.grey[800]),
                    onPressed: () => onRefresh()),
              ],
            )
          ],
        ),
        Divider(),
        Text('Neu', style: Theme.of(context).textTheme.headlineSmall),
        Text(
          'Zurzeit ${_drafts.length == 1 ? 'ist' : 'sind'} ${_drafts.length} ${_drafts.length == 1 ? 'Entwurf' : 'Entwürfe'} vorhanden.',
          style: TextStyle(color: Colors.grey[800]),
          overflow: TextOverflow.ellipsis,
        ),
        if (_drafts.isNotEmpty)
          Flexible(
              child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  height: (widget.filter != null && widget.filter > 0) ? 93.0 : 109.0, width: 0.0),
              ..._drafts.take(4).map<Widget>((Draft d) {
                final customers = _customers?.where((Customer c) => c.id == d.customer) ?? [];
                final vendors = _vendors?.where((Vendor v) => v.id == d.vendor) ?? [];
                return Expanded(
                  child: DraftShortcut(context,
                      draft: d,
                      vendor: vendors.isNotEmpty ? vendors.first : null,
                      customer: customers.isNotEmpty ? customers.first : null,
                      showVendor: widget.filter == null),
                );
              }),
              if (_drafts.length > 4)
                Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0))
              else if (_drafts.isNotEmpty)
                Container(width: 48.0, height: 48.0),
              for (var i = 0; i < (4 - _drafts.length); i++) Spacer(),
            ],
          )),
      ],
    );
  }

  Future<void> initDb() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final db = InheritedDatabase.of(context);
    _draftRepo = DraftRepository(db);
    _customerRepo = CustomerRepository(db);
    _vendorRepo = VendorRepository(db);

    try {
      await _draftRepo.setUp();
      await _customerRepo.setUp();
      await _vendorRepo.setUp();
      await onRefresh();
    } on NoSuchMethodError {
      print('db not available');
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> onRefresh() async {
    _customers = await _customerRepo.select();
    _vendors = await _vendorRepo.select(short: true);
    _drafts = await _draftRepo.select();
    if (widget.filter != null && widget.filter > 0) {
      _drafts.removeWhere((Draft d) => d.vendor != widget.filter);
    }
    _drafts.sort((Draft a, Draft b) => b.id.compareTo(a.id));
    if (mounted) setState(() => _drafts);
  }
}
