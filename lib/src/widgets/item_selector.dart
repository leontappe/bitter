import 'package:flutter/material.dart';

import '../providers/inherited_database.dart';
import '../repositories/item_repository.dart';

class ItemSelector extends StatefulWidget {
  final int initialValue;
  final Function(Item) onChanged;
  final bool disabled;

  const ItemSelector({
    Key key,
    @required this.onChanged,
    @required this.initialValue,
    this.disabled = false,
  }) : super(key: key);

  @override
  _ItemSelectorState createState() => _ItemSelectorState();
}

class _ItemSelectorState extends State<ItemSelector> {
  ItemRepository repo;

  List<Item> _items = [];
  Item _item = Item.empty();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      hint: Text((widget.disabled) ? _item?.title ?? '' : 'Artikel auswählen'),
      isExpanded: true,
      value: _item?.id,
      onChanged: (widget.disabled)
          ? null
          : (int value) {
              setState(() => _item = _items.singleWhere((Item i) => i.id == value));
              widget.onChanged(_item);
            },
      items: <DropdownMenuItem<int>>[
        ..._items
            .map<DropdownMenuItem<int>>(
                (Item i) => DropdownMenuItem<int>(value: i.id, child: Text('${i.title}')))
            .toList()
      ],
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = ItemRepository(InheritedDatabase.of(context));

    await repo.setUp();

    _items = await repo.select();

    if (widget.initialValue != null) {
      try {
        _item = await repo.selectSingle(widget.initialValue);
      } catch (e) {
        print(e);
      }
    }

    if (mounted) setState(() => _items);
  }

  @override
  void initState() {
    super.initState();
  }
}
