import 'package:flutter/material.dart';

import '../models/item.dart';

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
  Item _item;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        title: TextFormField(
          onChanged: (String input) {
            setState(() => _item.title = input);
          },
          decoration: InputDecoration(hintText: 'Artikelbezeichnung'),
        ),
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
