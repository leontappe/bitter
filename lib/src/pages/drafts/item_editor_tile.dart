import 'package:flutter/material.dart';

import '../../models/item.dart';

enum EditorTileAction { delete, save }

class ItemEditorTile extends StatelessWidget {
  final Item item;
  final int defaultTax;
  final Function(Item) itemChanged;
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
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50.0,
        child: TextFormField(
          initialValue: item.quantity?.toString() ?? '1',
          onChanged: (String input) {
            item.quantity = int.parse(input);
            itemChanged(item);
          },
          decoration: InputDecoration(suffixText: 'x', hintText: 'Menge'),
        ),
      ),
      title: TextFormField(
        initialValue: item.title ?? '',
        onChanged: (String input) {
          item.title = input;
          itemChanged(item);
        },
        decoration: InputDecoration(hintText: 'Artikelbezeichnung'),
      ),
      subtitle: TextFormField(
        initialValue: item.description ?? '',
        onChanged: (String input) {
          item.description = input;
          itemChanged(item);
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
              initialValue: item.tax?.toString() ?? defaultTax.toString() ?? '19',
              onChanged: (String input) {
                item.tax = int.tryParse(input) ?? defaultTax;
                itemChanged(item);
              },
              decoration: InputDecoration(suffixText: '%', hintText: 'Steuer'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            width: 80.0,
            child: TextFormField(
              initialValue:
                  (item.price != null) ? (item.price.toDouble() / 100.0).toStringAsFixed(2) : '',
              onChanged: (String input) {
                item.price = (double.parse(input.replaceAll(',', '.')) * 100).toInt();
                itemChanged(item);
              },
              decoration: InputDecoration(suffixText: '€', hintText: 'Preis'),
            ),
          ),
          PopupMenuButton<EditorTileAction>(
            onSelected: (EditorTileAction action) {
              switch (action) {
                case EditorTileAction.delete:
                  itemDeleted(item);
                  break;
                case EditorTileAction.save:
                  itemSaved(item);
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
}
