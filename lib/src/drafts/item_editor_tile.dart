import 'package:flutter/material.dart';

import '../models/item.dart';

class ItemEditorTile extends StatefulWidget {
  final Item item;
  final int defaultTax;
  final Function(Item) itemChanged;
  final Function(Item) itemDeleted;

  ItemEditorTile({
    @required this.item,
    @required this.defaultTax,
    @required this.itemChanged,
    @required this.itemDeleted,
  });

  @override
  _ItemEditorTileState createState() => _ItemEditorTileState();
}

class _ItemEditorTileState extends State<ItemEditorTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50.0,
        child: TextFormField(
          controller: TextEditingController(text: widget.item.quantity?.toString() ?? '1'),
          onChanged: (String input) {
            setState(() => widget.item.quantity = int.parse(input));
            widget.itemChanged(widget.item);
          },
          decoration: InputDecoration(suffixText: 'x', hintText: 'Menge'),
        ),
      ),
      title: TextFormField(
        controller: TextEditingController(text: widget.item.title ?? ''),
        onChanged: (String input) {
          setState(() => widget.item.title = input);
          widget.itemChanged(widget.item);
        },
        decoration: InputDecoration(hintText: 'Artikelbezeichnung'),
      ),
      subtitle: TextFormField(
        controller: TextEditingController(text: widget.item.description ?? ''),
        onChanged: (String input) {
          setState(() => widget.item.description = input);
          widget.itemChanged(widget.item);
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
              controller: TextEditingController(text: widget.defaultTax.toString() ?? ''),
              onChanged: (String input) {
                setState(() => widget.item.tax = int.tryParse(input) ?? widget.defaultTax);
                widget.itemChanged(widget.item);
              },
              decoration: InputDecoration(suffixText: '%', hintText: 'Steuer'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            width: 80.0,
            child: TextFormField(
              controller: TextEditingController(
                  text: (widget.item.price != null)
                      ? (widget.item.price.toDouble() / 100.0).toStringAsFixed(2)
                      : ''),
              onChanged: (String input) {
                setState(() =>
                    widget.item.price = (double.parse(input.replaceAll(',', '.')) * 100).toInt());
                widget.itemChanged(widget.item);
              },
              decoration: InputDecoration(suffixText: '€', hintText: 'Preis'),
            ),
          ),
          IconButton(icon: Icon(Icons.delete), onPressed: () => widget.itemDeleted(widget.item))
        ],
      ),
    );
  }
}
