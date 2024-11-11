import 'dart:async';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../util/format_util.dart';
import '../../widgets/database_error_watcher.dart';
import '../../widgets/gestureless_list_tile.dart';
import '../../widgets/vendor_selector.dart';
import 'draft_popup_menu.dart';
import 'item_editor_tile.dart';
import 'items_bloc.dart';

class DraftCreatorPage extends StatefulWidget {
  final Draft draft;

  const DraftCreatorPage({Key key, this.draft}) : super(key: key);

  @override
  _DraftCreatorPageState createState() => _DraftCreatorPageState();
}

class _DraftCreatorPageState extends State<DraftCreatorPage> {
  final _formKey = GlobalKey<FormState>();

  DraftRepository repo;
  CustomerRepository customerRepo;
  SettingsRepository settingsRepo;
  ItemRepository itemRepo;
  VendorRepository vendorRepo;

  ItemsBloc itemsBloc;

  String editor;

  Draft draft;
  bool dirty;
  bool changed;

  bool customerIsset = false;
  bool vendorIsset = false;
  List<Customer> _customers;
  Vendor _vendor;
  Customer _customer;

  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) => IconButton(
                  tooltip: 'Zurück',
                  icon: Icon((widget.draft != null) ? Icons.arrow_back_ios : Icons.cancel),
                  onPressed: () => onPopRoute(context),
                )),
        title: Text(
            (widget.draft != null) ? 'Entwurf ${widget.draft.id}' : 'Rechnungsentwurf hinzufügen'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (busy) ? null : onSaveDraft,
            tooltip: 'Rechnungsentwurf abspeichern',
          ),
          if (widget.draft != null)
            DraftPopupMenu(
              id: draft.id,
              onStarted: () => setState(() => busy = true),
              onCompleted: (bool changed, bool redirect) {
                setState(() => busy = false);
                redirect
                    ? Navigator.popAndPushNamed(context, '/bills', result: changed)
                    : changed
                        ? Navigator.pop(context, changed)
                        : null;
              },
            )
        ],
      ),
      body: DatabaseErrorWatcher(
        child: (busy)
            ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
            : Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      GesturelessListTile(
                        title: Text('Kunde', style: Theme.of(context).textTheme.headlineSmall),
                        trailing:
                            (customerIsset ?? true) ? null : Icon(Icons.error, color: Colors.red),
                        subtitle: AutoCompleteTextField<Customer>(
                          key: GlobalKey<AutoCompleteTextFieldState<Customer>>(),
                          controller: TextEditingController(
                              text: _customer?.fullCompany ?? _customer?.fullName ?? ''),
                          itemSubmitted: (Customer c) {
                            setState(() {
                              draft.customer = c.id;
                              _customer = c;
                            });
                            dirty = true;
                            validateDropdowns();
                          },
                          suggestions: _customers,
                          itemBuilder: (BuildContext context, Customer c) => ListTile(
                            title: Text((c.company != null)
                                ? '${c.company}${c.organizationUnit != null ? ' ' + c.organizationUnit : ''}'
                                : '${c.name} ${c.surname}'),
                            subtitle: (c.company != null) ? Text('${c.name} ${c.surname}') : null,
                          ),
                          itemSorter: (Customer a, Customer b) => a.id - b.id,
                          itemFilter: (Customer c, String filter) {
                            if (filter == null || filter.isEmpty) return true;
                            filter = filter.toLowerCase();
                            return (c.fullName ?? '').toLowerCase().contains(filter) ||
                                (c.fullCompany ?? '').toLowerCase().contains(filter);
                          },
                        ),
                      ),
                      GesturelessListTile(
                        title: Text('Verkäufer', style: Theme.of(context).textTheme.headlineSmall),
                        trailing:
                            (vendorIsset ?? true) ? null : Icon(Icons.error, color: Colors.red),
                        subtitle: VendorSelector(
                          initialValue: draft?.vendor,
                          onChanged: (Vendor v) {
                            draft.vendor = v.id;
                            _vendor = v;
                            draft.tax = _vendor.defaultTax;
                            draft.dueDays = _vendor.defaultDueDays;
                            dirty = true;
                            validateDropdowns();
                          },
                        ),
                      ),
                      GesturelessListTile(
                        height: 64.0,
                        title: Text('Lieferdatum/Leistungsdatum:',
                            style: Theme.of(context).textTheme.headlineSmall),
                        trailing: Container(
                          width: 196.0,
                          height: 64.0,
                          child: MaterialButton(
                            onPressed: (vendorIsset)
                                ? () async {
                                    draft.serviceDate = await showDatePicker(
                                      context: context,
                                      initialDate: draft.serviceDate ?? DateTime.now(),
                                      firstDate: DateTime(DateTime.now().year - 20),
                                      lastDate: DateTime(DateTime.now().year + 20),
                                      cancelText: 'Löschen',
                                      confirmText: 'Übernehmen',
                                    );
                                    setState(() => draft);
                                    dirty = true;
                                  }
                                : null,
                            child: Text((draft.serviceDate != null)
                                ? formatDate(draft.serviceDate)
                                : 'Am Rechnungsdatum'),
                          ),
                        ),
                      ),
                      GesturelessListTile(
                        height: 64.0,
                        title: Text('Zahlungsziel:', style: Theme.of(context).textTheme.headlineSmall),
                        trailing: Container(
                          width: 80.0,
                          height: 64.0,
                          child: TextFormField(
                            enabled: vendorIsset,
                            controller:
                                TextEditingController(text: draft.dueDays?.toString() ?? '14'),
                            maxLines: 1,
                            keyboardType: TextInputType.numberWithOptions(),
                            decoration: InputDecoration(hintText: '14', suffixText: 'Tage'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              setState(() => draft.dueDays = int.parse(input));
                              _formKey.currentState.validate();
                              dirty = true;
                            },
                          ),
                        ),
                      ),
                      if (_vendor?.userMessageLabel != null && _vendor.userMessageLabel.isNotEmpty)
                        GesturelessListTile(
                          title: Text(
                              '${_vendor?.userMessageLabel}:' ??
                                  'Benutzerdefinierter Rechnungskommentar:',
                              style: Theme.of(context).textTheme.headlineSmall),
                          trailing: Container(
                            width: 256.0,
                            child: TextFormField(
                              initialValue: draft.userMessage,
                              onChanged: (String input) {
                                setState(() => draft.userMessage = input);
                                dirty = true;
                              },
                            ),
                          ),
                        ),
                      GesturelessListTile(
                        title: Text('Rechnungskommentar:',
                            style: Theme.of(context).textTheme.headlineSmall),
                        trailing: Container(
                          width: 256.0,
                          child: TextFormField(
                            controller: TextEditingController(
                                text: draft.comment ?? _vendor?.defaultComment ?? ''),
                            maxLines: 2,
                            onChanged: (String input) {
                              draft.comment = input;
                              dirty = true;
                            },
                          ),
                        ),
                      ),
                      Text('Artikel', style: Theme.of(context).textTheme.headlineSmall),
                      BlocBuilder<ItemsBloc, ItemsState>(
                        bloc: itemsBloc,
                        builder: (BuildContext context, ItemsState state) {
                          if (state.items != null) {
                            return Column(children: <Widget>[
                              ...state.items.map<ItemEditorTile>((Item e) => ItemEditorTile(
                                    item: e,
                                    defaultTax: draft.tax,
                                    itemChanged: onUpdateItem,
                                    itemDeleted: (Item e) => onRemoveItem(e.uid),
                                    itemSaved: onSaveItem,
                                  )),
                            ]);
                          }
                          return Container(width: 0.0, height: 0.0);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: (vendorIsset)
                                ? () => onAddItem(Item(
                                    price: null,
                                    title: '',
                                    tax: _vendor.defaultTax ?? 19,
                                    vendor: _vendor.id))
                                : null,
                            child: Icon(Icons.add, size: 32.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
    if (mounted) setState(() => busy = true);

    final db = InheritedDatabase.of(context);
    db.errors.listen(print);

    repo = DraftRepository(db);
    customerRepo = CustomerRepository(db);
    itemRepo = ItemRepository(db);
    vendorRepo = VendorRepository(db);
    settingsRepo = SettingsRepository();

    await itemRepo.setUp();
    await settingsRepo.setUp();
    await vendorRepo.setUp();

    editor = settingsRepo.getUsername();
    _customers = await customerRepo.select();

    if (vendorIsset) {
      try {
        _vendor = await vendorRepo.selectSingle(draft.vendor);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Der bisherige Verkäufer ist nicht mehr verfügbar oder wurde gelöscht.'),
          duration: Duration(seconds: 5),
        ));
        setState(() => draft.vendor = null);
        //await onSaveDraft();
      }
    }
    if (customerIsset) {
      try {
        _customer = await customerRepo.selectSingle(draft.customer);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Der bisherige Kunde ist nicht mehr verfügbar oder wurde gelöscht.'),
          duration: Duration(seconds: 5),
        ));
        setState(() => draft.customer = null);
        //await onSaveDraft();
      }
    }

    if (mounted) setState(() => busy = false);
  }

  @override
  void initState() {
    itemsBloc = ItemsBloc();

    if (widget.draft != null) {
      draft = widget.draft;
      draft.items.forEach(updateItemVendor);
      itemsBloc.onBulkAdd(draft.items);
      vendorIsset = draft.vendor != null;
      customerIsset = draft.customer != null;
    } else {
      draft = Draft.empty();
    }

    _customers = [];
    dirty = false;
    changed = false;

    super.initState();
  }

  void onAddItem(Item item) {
    itemsBloc.onAddItem(item);
    dirty = true;
  }

  Future<void> onPopRoute(BuildContext context) async {
    if (dirty) {
      final result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Wenn du ohne Speichern fortfährst gehen alle hier eingegebenen Daten verloren. Vor dem Verlassen abspeichern?'),
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
          if (!await onSaveDraft()) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
      Navigator.pop<bool>(context, changed);
    }
  }

  void onRemoveItem(String id) {
    itemsBloc.onRemoveItem(id);
    dirty = true;
  }

  Future<bool> onSaveDraft() async {
    if (_formKey.currentState.validate() && validateDropdowns()) {
      if (mounted) setState(() => busy = true);
      draft.items = itemsBloc.items;

      for (var i = 0; i < draft.items.length; i++) {
        if (draft.items[i].tax == null) {
          draft.items[i].tax = draft.tax;
        }
        draft.items[i].vendor = _vendor.id;
      }

      draft.editor = editor;

      if (_vendor.defaultComment != null &&
          _vendor.defaultComment.isNotEmpty &&
          (draft.comment?.isEmpty ?? true)) {
        draft.comment = _vendor.defaultComment;
      }

      if (widget.draft != null) {
        await repo.update(draft);
      } else {
        await repo.insert(draft);
      }

      dirty = false;
      if (widget.draft == null) {
        Navigator.pop<bool>(context, true);
      }
      changed = true;
      if (mounted) setState(() => busy = false);
      return true;
    }
    return false;
  }

  Future<void> onSaveItem(Item item) async {
    final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(
                  'Willst du \'${item.title}\' wirklich zur Artikeldatenbank hinzufügen? Danach kannst du den Artikel über die Auto-Vervollständigung im Namensfeld aufrufen.'),
              actions: <Widget>[
                MaterialButton(
                    onPressed: () => Navigator.pop(context, false), child: Text('Abbrechen')),
                MaterialButton(
                    onPressed: () => Navigator.pop(context, true), child: Text('Artikel sichern')),
              ],
            ));
    if (result) {
      item.quantity = 1;
      await itemRepo.insert(item);
    }
  }

  void onUpdateItem(Item item, bool updateState) {
    if (updateState) itemsBloc.onUpdateItem(item);
    dirty = true;
  }

  void updateItemVendor(Item i) => i.vendor = draft.vendor;

  bool validateDropdowns() {
    setState(() {
      vendorIsset = draft.vendor != null;
      customerIsset = draft.customer != null;
    });

    return vendorIsset && customerIsset;
  }
}
