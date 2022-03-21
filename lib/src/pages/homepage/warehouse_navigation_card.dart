import 'package:flutter/material.dart';

import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../widgets/navigation_card.dart';

class WarehouseNavigationCard extends StatefulWidget {
  final int filter;

  WarehouseNavigationCard({this.filter}) : super(key: Key(filter.toString()));

  @override
  _ItemsNavigationCardState createState() => _ItemsNavigationCardState();
}

class _ItemsNavigationCardState extends State<WarehouseNavigationCard> {
  ItemRepository _itemRepo;
  VendorRepository _vendorRepo;

  List<Item> _items = [];
  List<Vendor> _vendors;

  @override
  Widget build(BuildContext context) {
    return NavigationCard(
      context,
      '/warehouse',
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(
              'Warenverwaltung',
              style: Theme.of(context).textTheme.headline5,
              overflow: TextOverflow.ellipsis,
            )),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    tooltip: 'Neue Buchung erstellen',
                    icon: Icon(Icons.add, color: Colors.grey[700]),
                    onPressed: () async {}),
                IconButton(
                    tooltip: 'Aktualisieren',
                    icon: Icon(Icons.refresh, color: Colors.grey[800]),
                    onPressed: () => onRefresh()),
              ],
            )
          ],
        ),
        Divider(),
      ],
    );
  }

  Future<void> initDb() async {
    await Future.delayed(const Duration(milliseconds: 400));
     if (!mounted) return;

    _itemRepo = ItemRepository(InheritedDatabase.of(context));
    _vendorRepo = VendorRepository(InheritedDatabase.of(context));

    try {
      await _itemRepo.setUp();
      await _vendorRepo.setUp();
      await onRefresh();
      _vendors = await _vendorRepo.select();
    } on NoSuchMethodError {
      print('db not availiable');
      return;
    }

    if (mounted) setState(() => _vendors);
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> onRefresh() async {
    _items = await _itemRepo.select();
    if (widget.filter != null && widget.filter > 0) {
      _items.removeWhere((Item i) => i.vendor != widget.filter);
    }
    _items.sort((Item a, Item b) => b.id.compareTo(a.id));
    if (mounted) setState(() => _items);
  }
}
