import 'package:bitter/src/models/vendor.dart';
import 'package:bitter/src/widgets/item_card.dart';
import 'package:bitter/src/widgets/vendor_selector.dart';
import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';

class ItemPage extends StatefulWidget {
  final Item item;

  ItemPage({this.item});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<ItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ItemRepository repo;

  Item item = Item.empty();

  bool dirty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) => IconButton(
                  tooltip: 'Zurück',
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => onPopRoute(context),
                )),
        title: Text((widget.item != null) ? widget.item.title : 'Artikel erstellen'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: onSaveItem),
        ],
      ),
      body: ListView(
        children: <Widget>[
          if (widget.item != null) ItemCard(item: widget.item),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, (widget.item != null) ? 16.0 : 8.0, 16.0, 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  VendorSelector(
                    onChanged: (Vendor v) {
                      item.vendor = v.id;
                    },
                    initialValue: item.vendor,
                  ),
                  TextFormField(
                    initialValue: item.title ?? '',
                    maxLines: 1,
                    decoration: InputDecoration(labelText: 'Titel'),
                    validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                    onChanged: (String input) {
                      item.title = input;
                      _formKey.currentState.validate();
                      dirty = true;
                    },
                  ),
                  TextFormField(
                    initialValue: item.description ?? '',
                    maxLines: 1,
                    decoration: InputDecoration(labelText: 'Beschreibung'),
                    validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                    onChanged: (String input) {
                      item.description = input;
                      _formKey.currentState.validate();
                      dirty = true;
                    },
                  ),
                  TextFormField(
                    initialValue: item?.price?.toString() ?? '',
                    onChanged: (String input) {
                      setState(() =>
                          item.price = (double.parse(input.replaceAll(',', '.')) * 100).toInt());
                    },
                    decoration: InputDecoration(suffixText: '€', hintText: 'Preis'),
                  ),
                  TextFormField(
                    maxLines: 1,
                    initialValue: item.tax?.toString() ?? '19',
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(labelText: 'Umsatzsteuer', suffixText: '%'),
                    validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                    onChanged: (String input) {
                      item.tax = int.parse(input);
                      _formKey.currentState.validate();
                      dirty = true;
                    },
                  ),
                  TextFormField(
                    maxLines: 1,
                    initialValue: item.quantity?.toString() ?? '1',
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(labelText: 'Menge', suffixText: 'x'),
                    validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                    onChanged: (String input) {
                      item.quantity = int.parse(input);
                      _formKey.currentState.validate();
                      dirty = true;
                    },
                  ),
                ],
              ),
            ),
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

    if (widget.item != null) {
      item = widget.item;
    }

    setState(() => item);
  }

  Future<void> onPopRoute(BuildContext context) async {
    if (dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Wenn du ohne Speichern fortfährst gehen alle hier eingebenen Daten verloren. Vor dem Verlassen abspeichern?'),
                actions: <Widget>[
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, -1), child: Text('Abbrechen')),
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, 0), child: Text('Verwerfen')),
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, 1), child: Text('Speichern')),
                ],
              ));
      switch (result) {
        case 0:
          Navigator.pop<bool>(context, false);
          break;
        case 1:
          if (!await onSaveItem()) {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Es gibt noch Fehler und/oder fehlende Felder in dem Formular, sodass gerade nicht gespeichert werden kann.'),
              duration: Duration(seconds: 3),
            ));
          } else {
            Navigator.pop(context, true);
          }
          break;
        default:
          return;
      }
    } else {
      Navigator.pop<bool>(context, false);
    }
  }

  Future<bool> onSaveItem() async {
    if (_formKey.currentState.validate()) {
      if (widget.item != null) {
        await repo.update(item);
        dirty = false;
      } else {
        await repo.insert(item);
        dirty = false;
        await onPopRoute(context);
      }
      return true;
    }
    return false;
  }
}
