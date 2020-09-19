import 'package:flutter/material.dart';

import '../../models/draft.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../widgets/shortcuts/draft_shortcut.dart';
import '../../widgets/navigation_card.dart';
import '../drafts/draft_creator.dart';

class DraftsNavigationCard extends StatefulWidget {
  final int filter;

  DraftsNavigationCard({this.filter}) : super(key: Key(filter.toString()));

  @override
  _DraftsNavigationCardState createState() => _DraftsNavigationCardState();
}

class _DraftsNavigationCardState extends State<DraftsNavigationCard> {
  DraftRepository _billRepo;
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
                    style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis)),
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
        Text('Neu', style: Theme.of(context).textTheme.headline4),
        Text(
          ' Zurzeit sind ${_drafts.length} Entwürfe vorhanden.',
          style: TextStyle(color: Colors.grey[800]),
          overflow: TextOverflow.ellipsis,
        ),
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._drafts.take(4).map<Widget>((Draft d) => Expanded(
                  child: DraftShortcut(context,
                      draft: d,
                      vendor: _vendors?.singleWhere((Vendor v) => v.id == d.vendor),
                      customer: _customers?.singleWhere((Customer c) => c.id == d.customer),
                      showVendor: widget.filter == null),
                )),
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

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    _billRepo = DraftRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    _customerRepo = CustomerRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    _vendorRepo = VendorRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);

    await _billRepo.setUp();
    await _customerRepo.setUp();
    await _vendorRepo.setUp();

    await onRefresh();
  }

  Future<void> onRefresh() async {
    _customers = await _customerRepo.select();
    _vendors = await _vendorRepo.select();
    _drafts = await _billRepo.select();
    if (widget.filter != null && widget.filter > 0) {
      _drafts.removeWhere((Draft d) => d.vendor != widget.filter);
    }
    _drafts.sort((Draft a, Draft b) => b.id.compareTo(a.id));
    if (mounted) setState(() => _drafts);
  }
}
