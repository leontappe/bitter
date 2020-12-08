import 'package:flutter/material.dart';

import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../widgets/navigation_card.dart';
import '../../widgets/shortcuts/item_shortcut.dart';
import '../items/item_page.dart';

class ItemsNavigationCard extends StatefulWidget {
  final int filter;

  ItemsNavigationCard({this.filter}) : super(key: Key(filter.toString()));

  @override
  _ItemsNavigationCardState createState() => _ItemsNavigationCardState();
}

class _ItemsNavigationCardState extends State<ItemsNavigationCard> {
  ItemRepository _itemRepo;
  VendorRepository _vendorRepo;

  List<Item> _items = [];
  List<Vendor> _vendors;

  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return NavigationCard(
      context,
      '/items',
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text('Artikel',
                    style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    tooltip: 'Neuen Artikel erstellen',
                    icon: Icon(Icons.add, color: Colors.grey[700]),
                    onPressed: () async {
                      await Navigator.push<bool>(context,
                          MaterialPageRoute<bool>(builder: (BuildContext context) => ItemPage()));
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
          ' Zurzeit ${_items.length == 1 ? 'ist' : 'sind'} ${_items.length} Artikel vorhanden.',
          style: TextStyle(color: Colors.grey[800]),
          overflow: TextOverflow.ellipsis,
        ),
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (busy)
              Container(
                  height: (widget.filter != null && widget.filter > 0) ? 77.0 : 93.0, width: 0.0),
            ..._items.take(4).map<Widget>((Item i) {
              final vendors = _vendors?.where((Vendor v) => v.id == i.vendor) ?? [];
              return Expanded(
                child: ItemShortcut(context,
                    item: i,
                    vendor: vendors.isNotEmpty ? vendors.first : null,
                    showVendor: widget.filter == null),
              );
            }),
            if (_items.length > 4)
              Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0))
            else if (_items.isNotEmpty)
              Container(width: 48.0, height: 48.0),
            for (var i = 0; i < (4 - _items.length); i++) Spacer(),
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
    if (mounted) setState(() => busy = true);
    _itemRepo = ItemRepository(InheritedDatabase.of(context));
    _vendorRepo = VendorRepository(InheritedDatabase.of(context));

    try {
      await _itemRepo.setUp();
      await _vendorRepo.setUp();
      await onRefresh();
      _vendors = await _vendorRepo.select();
    } on NoSuchMethodError {
      if (mounted) setState(() => busy = false);
      print('db not availiable');
      return;
    }

    if (mounted) setState(() => _vendors);
  }

  Future<void> onRefresh() async {
    _items = await _itemRepo.select();
    if (widget.filter != null && widget.filter > 0) {
      _items.removeWhere((Item i) => i.vendor != widget.filter);
    }
    _items.sort((Item a, Item b) => b.id.compareTo(a.id));
    if (mounted) setState(() => busy = false);
  }
}
