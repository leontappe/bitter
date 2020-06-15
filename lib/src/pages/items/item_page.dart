import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../models/vendor.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/item_repository.dart';
import '../../util.dart';
import '../../widgets/item_card.dart';
import '../../widgets/vendor_selector.dart';

class ItemPage extends StatefulWidget {
  final Item item;

  ItemPage({this.item});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
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
        title: Text((widget.item != null) ? 'Artikel bearbeiten' : 'Artikel erstellen'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: onSaveItem),
          if (widget.item != null)
            IconButton(icon: Icon(Icons.delete), onPressed: () => onDeleteItem(widget.item.id)),
        ],
      ),
      body: ListView(
        children: <Widget>[
          if (widget.item != null) ItemCard(item: item),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, (widget.item != null) ? 16.0 : 8.0, 16.0, 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  VendorSelector(
                    disabled: widget.item != null,
                    onChanged: (Vendor v) {
                      setState(() {
                        item.vendor = v.id;
                        item.tax = v.defaultTax;
                      });
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
                    onChanged: (String input) {
                      item.description = input;
                      dirty = true;
                    },
                  ),
                  ListTile(
                    title: Text('Preis', style: Theme.of(context).textTheme.headline6),
                    trailing: Container(
                      width: 94.0,
                      height: 64.0,
                      child: TextFormField(
                        initialValue: (item.price != null)
                            ? (item.price.toDouble() / 100.0).toStringAsFixed(2)
                            : '',
                        validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                        keyboardType: TextInputType.numberWithOptions(),
                        onChanged: (String input) {
                          setState(() => item.price = parseFloat(input));
                          dirty = true;
                          _formKey.currentState.validate();
                        },
                        decoration: InputDecoration(suffixText: '€'),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Umsatzsteuer', style: Theme.of(context).textTheme.headline6),
                    trailing: Container(
                      width: 94.0,
                      height: 64.0,
                      child: TextFormField(
                        maxLines: 1,
                        controller: TextEditingController(text: item.tax.toString()),
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(suffixText: '%'),
                        validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                        onChanged: (String input) {
                          item.tax = int.parse(input);
                          _formKey.currentState.validate();
                          dirty = true;
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Standardmenge', style: Theme.of(context).textTheme.headline6),
                    trailing: Container(
                      width: 94.0,
                      height: 64.0,
                      child: TextFormField(
                        maxLines: 1,
                        initialValue: item.quantity?.toString() ?? '1',
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(suffixText: 'x'),
                        validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                        onChanged: (String input) {
                          item.quantity = int.parse(input);
                          _formKey.currentState.validate();
                          dirty = true;
                        },
                      ),
                    ),
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

  Future<void> onDeleteItem(int id) async {
    var result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Soll dieser Artikel wirlich gelöscht werden?'),
        actions: <Widget>[
          MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Behalten')),
          MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Löschen')),
        ],
      ),
    );
    if (result == 1) {
      await repo.delete(id);
      await Navigator.pop(context, true);
    }
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
        setState(() => item);
      } else {
        await repo.insert(item);
        dirty = false;
        await Navigator.pop<bool>(context, true);
      }
      return true;
    }
    return false;
  }
}
