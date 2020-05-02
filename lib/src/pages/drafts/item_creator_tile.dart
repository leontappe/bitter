import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:bitter/src/providers/database_provider.dart';
import 'package:bitter/src/providers/inherited_database.dart';
import 'package:flutter/material.dart';

import '../../repositories/item_repository.dart';
import '../../models/item.dart';

class ItemCreatorTile extends StatefulWidget {
  final int defaultTax;
  final Function(Item) itemAdded;

  ItemCreatorTile({
    @required this.defaultTax,
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
        leading: Container(
          width: 50.0,
          child: TextFormField(
            initialValue: '1',
            onChanged: (String input) {
              setState(() => _item.quantity = int.parse(input));
            },
            decoration: InputDecoration(suffixText: 'x', hintText: 'Menge'),
          ),
        ),
        title: AutoCompleteTextField<Item>(
          key: GlobalKey<AutoCompleteTextFieldState<Item>>(),
          textCapitalization: TextCapitalization.sentences,
          itemSubmitted: (Item item) {
            print(item);
            setState(() {
              _item = item;
            });
          },
          suggestions: _items,
          itemBuilder: (BuildContext context, Item item) => Text(item.title),
          itemSorter: (Item a, Item b) => a.id > b.id ? -1 : 1, //TODO: meaningful sorting
          itemFilter: (Item item, String query) =>
              item.title.toLowerCase().contains(query.toLowerCase()),
        ),
        /*TextFormField(
          enableSuggestions: true,
          onChanged: (String input) {
            setState(() => _item.title = input);
          },
          decoration: InputDecoration(hintText: 'Artikelbezeichnung'),
        ),*/
        subtitle: TextFormField(
          onChanged: (String input) {
            setState(() => _item.description = input);
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
                initialValue: widget.defaultTax.toString() ?? '',
                onChanged: (String input) {
                  setState(() => _item.tax = int.tryParse(input) ?? widget.defaultTax);
                },
                decoration: InputDecoration(suffixText: '%', hintText: 'Steuer'),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              width: 80.0,
              child: TextFormField(
                onChanged: (String input) {
                  setState(
                      () => _item.price = (double.parse(input.replaceAll(',', '.')) * 100).toInt());
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

  Future<void> initDb() async {
    repo = ItemRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    await repo.setUp();

    _items = await repo.select();

    setState(() => _items);
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _item = Item.empty();
    super.initState();
  }

  void _onItemAdded() {
    widget.itemAdded(_item);
    _item = Item.empty();
    _formKey.currentState.reset();
  }
}
