import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';

enum EditorTileAction { delete, save }

class ItemEditorTile extends StatefulWidget {
  final Item item;
  final int defaultTax;
  final Function(Item, bool) itemChanged;
  final Function(Item) itemDeleted;
  final Function(Item) itemSaved;

  ItemEditorTile({
    @required this.item,
    @required this.defaultTax,
    @required this.itemChanged,
    @required this.itemDeleted,
    @required this.itemSaved,
  });

  @override
  Key get key => Key(item.uid);

  @override
  _ItemEditorTileState createState() => _ItemEditorTileState();
}

class _ItemEditorTileState extends State<ItemEditorTile> {
  ItemRepository repo;

  List<Item> _items = [];
  Item _item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50.0,
        child: TextFormField(
          initialValue: _item.quantity?.toString() ?? '1',
          onChanged: (String input) {
            _item.quantity = int.parse(input);
            widget.itemChanged(_item, false);
          },
          onFieldSubmitted: (String input) => widget.itemChanged(_item, true),
          decoration: InputDecoration(suffixText: 'x', hintText: 'Menge'),
        ),
      ),
      title: AutoCompleteTextField<Item>(
        controller: TextEditingController(text: _item.title ?? ''),
        key: GlobalKey<AutoCompleteTextFieldState<Item>>(),
        textCapitalization: TextCapitalization.sentences,
        textChanged: (String input) {
          _item.title = input;
        },
        itemSubmitted: _onItemSubmitted,
        suggestions: _items,
        itemBuilder: (BuildContext context, Item item) => ListTile(title: Text(item.title)),
        itemSorter: (Item a, Item b) => a.id > b.id ? -1 : 1, //TODO: meaningful sorting
        itemFilter: (Item item, String query) =>
            item.title.toLowerCase().startsWith(query.toLowerCase()),
      ),
      subtitle: TextFormField(
        controller: TextEditingController(text: _item.description),
        onChanged: (String input) {
          _item.description = input;
          widget.itemChanged(_item, false);
        },
        onFieldSubmitted: (String input) => widget.itemChanged(_item, true),
        decoration: InputDecoration(hintText: 'Beschreibung (optional)'),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            width: 80.0,
            child: TextFormField(
              controller: TextEditingController(
                  text: _item.tax?.toString() ?? widget.defaultTax.toString() ?? '19'),
              onChanged: (String input) {
                _item.tax = int.tryParse(input) ?? widget.defaultTax;
                widget.itemChanged(_item, false);
              },
              onFieldSubmitted: (String input) => widget.itemChanged(_item, true),
              decoration: InputDecoration(suffixText: '%', hintText: 'Steuer'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            width: 80.0,
            child: TextFormField(
              controller: TextEditingController(
                  text: (_item.price != null) ? (_item.price / 100.0).toStringAsFixed(2) : null),
              onChanged: (String input) {
                final split = input.replaceAll(',', '.').split('.');
                _item.price = (int.parse(split.first) * 100) +
                    ((split.length > 1)
                        ? int.parse(
                            (split.last.length > 1) ? split.last.substring(0, 2) : split.last + '0')
                        : 0);
                widget.itemChanged(_item, false);
              },
              onFieldSubmitted: (String input) => widget.itemChanged(_item, true),
              decoration: InputDecoration(suffixText: '€', hintText: 'Preis'),
            ),
          ),
          PopupMenuButton<EditorTileAction>(
            onSelected: (EditorTileAction action) {
              switch (action) {
                case EditorTileAction.delete:
                  widget.itemDeleted(_item);
                  break;
                case EditorTileAction.save:
                  widget.itemSaved(_item);
                  break;
                default:
                  return;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<EditorTileAction>>[
              PopupMenuItem<EditorTileAction>(
                value: EditorTileAction.delete,
                child: Row(children: <Widget>[
                  Icon(Icons.delete),
                  Text(' Artikel Löschen',
                      style: TextStyle(color: Theme.of(context).iconTheme.color))
                ]),
              ),
              PopupMenuItem<EditorTileAction>(
                value: EditorTileAction.save,
                child: Row(children: <Widget>[
                  Icon(Icons.save),
                  Text(' Artikel speichern',
                      style: TextStyle(color: Theme.of(context).iconTheme.color))
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = ItemRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    await repo.setUp();

    if (_item.vendor != null) {
      _items = (await repo.select()).where((Item item) => item.vendor == _item.vendor).toList();
    } else {
      _items = await repo.select();
    }
    if (mounted) setState(() => _items);
  }

  @override
  void initState() {
    _item = widget.item;
    super.initState();
  }

  void _onItemSubmitted(Item item) {
    setState(() {
      _item = item;
      _item.uid = widget.item.uid;
    });
    widget.itemChanged(_item, true);
  }
}
