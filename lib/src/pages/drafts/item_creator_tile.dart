import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:bitter/src/providers/database_provider.dart';
import 'package:bitter/src/providers/inherited_database.dart';
import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../repositories/item_repository.dart';

class ItemCreatorTile extends StatefulWidget {
  final int defaultTax;
  final int vendorId;
  final Function(Item) itemAdded;

  ItemCreatorTile({
    @required this.defaultTax,
    @required this.vendorId,
    @required this.itemAdded,
  });

  @override
  _ItemCreatorTileState createState() => _ItemCreatorTileState();
}

class _ItemCreatorTileState extends State<ItemCreatorTile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ItemRepository repo;

  List<Item> _items = [];
  Item _item;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListTile(
        key: Key(widget.vendorId.toString() + DateTime.now().toString()),
        leading: Container(
          width: 50.0,
          child: TextFormField(
            controller: TextEditingController(text: _item.quantity.toString()),
            onChanged: (String input) {
              _item.quantity = int.parse(input);
            },
            decoration: InputDecoration(suffixText: 'x', hintText: 'Menge'),
          ),
        ),
        title: AutoCompleteTextField<Item>(
          controller: TextEditingController(text: _item.title),
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
        /*TextFormField(
          enableSuggestions: true,
          onChanged: (String input) {
            setState(() => _item.title = input);
          },
          decoration: InputDecoration(hintText: 'Artikelbezeichnung'),
        ),*/
        subtitle: TextFormField(
          controller: TextEditingController(text: _item.description),
          onChanged: (String input) {
            _item.description = input;
          },
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
                controller: TextEditingController(text: widget.defaultTax.toString()),
                onChanged: (String input) {
                  _item.tax = int.tryParse(input) ?? widget.defaultTax;
                },
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
                  _item.price = (double.parse(input.replaceAll(',', '.')) * 100).toInt();
                },
                decoration: InputDecoration(suffixText: '€', hintText: 'Preis'),
              ),
            ),
            if (widget.itemAdded != null)
              IconButton(
                tooltip: 'Artikel hinzufügen',
                icon: Icon(Icons.add),
                onPressed: () => _onItemAdded(),
              )
          ],
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
    repo = ItemRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    await repo.setUp();

    if (widget.vendorId != null) {
      _items = (await repo.select()).where((Item item) => item.vendor == widget.vendorId).toList();
    } else {
      _items = await repo.select();
    }
    if (mounted) setState(() => _items);
  }

  @override
  void initState() {
    _item = Item.empty();
    _item.vendor = widget.vendorId;
    super.initState();
  }

  void _onItemAdded() {
    widget.itemAdded(_item);
    setState(() {
      _item = Item.empty();
      _item.vendor = widget.vendorId;
    });
    _formKey.currentState.reset();
  }

  void _onItemSubmitted(Item item) {
    setState(() {
      _item = item;
    });
  }
}
