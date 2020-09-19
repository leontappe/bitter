import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../widgets/navigation_card.dart';
import '../../widgets/shortcuts/item_shortcut.dart';
import '../items/item_page.dart';

class ItemsNavigationCard extends StatefulWidget {
  @override
  _ItemsNavigationCardState createState() => _ItemsNavigationCardState();
}

class _ItemsNavigationCardState extends State<ItemsNavigationCard> {
  ItemRepository _itemRepo;

  List<Item> _items = [];

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
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._items.take(4).map<Widget>((Item i) => Expanded(
                  child: ItemShortcut(context, item: i),
                )),
            if (_items.length > 4)
              Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0)),
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
    _itemRepo = ItemRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    await _itemRepo.setUp();
    await onRefresh();
  }

  Future<void> onRefresh() async {
    _items = await _itemRepo.select();
    _items.sort((Item a, Item b) => b.id.compareTo(a.id));
    if (mounted) setState(() => _items);
  }
}
