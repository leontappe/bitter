import 'package:flutter/material.dart';

import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/draft_repository.dart';
import '../../widgets/database_error_watcher.dart';
import '../../widgets/info_cards/customer_card.dart';

class CustomerPage extends StatefulWidget {
  final int id;

  CustomerPage({this.id});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _formKey = GlobalKey<FormState>();

  CustomerRepository repo;
  Customer customer;

  DraftRepository draftRepo;

  int dropdownValue = 2;

  Customer newCustomer = Customer.empty();

  bool dirty = false;
  bool changed = false;

  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Zurück',
          icon: Icon(widget.id != null ? Icons.arrow_back_ios : Icons.cancel),
          onPressed: onPopRoute,
        ),
        title: Text(widget.id != null ? 'Kundenansicht' : 'Kunden hinzufügen'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Diesen Kunden speichern',
            icon: Icon(Icons.save),
            onPressed: (busy) ? null : onSaveCustomer,
          ),
          if (widget.id != null)
            IconButton(
              tooltip: 'Diesen Kunden löschen',
              icon: Icon(Icons.delete),
              onPressed: (busy) ? null : onDeleteCustomer,
            ),
        ],
      ),
      body: (busy)
          ? Center(child: CircularProgressIndicator(strokeWidth: 5.0))
          : DatabaseErrorWatcher(
              child: ListView(
                semanticChildCount: 4,
                children: <Widget>[
                  if (widget.id != null)
                    Text(' Aktuelle Informationen', style: Theme.of(context).textTheme.headline4),
                  if (widget.id != null) CustomerCard(customer: customer),
                  if (widget.id != null)
                    Text(' Kunde bearbeiten', style: Theme.of(context).textTheme.headline4),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, (widget.id != null) ? 16.0 : 8.0, 16.0, 8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            initialValue: newCustomer.company,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Organisation'),
                            onChanged: (String input) {
                              newCustomer.company = input;
                              dirty = true;
                              changed = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newCustomer.organizationUnit,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Abteilung'),
                            onChanged: (String input) {
                              newCustomer.organizationUnit = input;
                              dirty = true;
                              changed = true;
                            },
                          ),
                          TextFormField(
                              initialValue: newCustomer.name,
                              maxLines: 1,
                              decoration: InputDecoration(labelText: 'Vorname'),
                              validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                              onChanged: (String input) {
                                newCustomer.name = input;
                                _formKey.currentState.validate();
                                dirty = true;
                                changed = true;
                              }),
                          TextFormField(
                              initialValue: newCustomer.surname,
                              maxLines: 1,
                              decoration: InputDecoration(labelText: 'Nachname'),
                              validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                              onChanged: (String input) {
                                newCustomer.surname = input;
                                _formKey.currentState.validate();
                                dirty = true;
                                changed = true;
                              }),
                          DropdownButton(
                              hint: Text('Geschlecht'),
                              value: dropdownValue,
                              items: [
                                DropdownMenuItem(value: 0, child: Text('männlich')),
                                DropdownMenuItem(value: 1, child: Text('weiblich')),
                                DropdownMenuItem(value: 2, child: Text('divers')),
                              ],
                              onChanged: (int v) {
                                newCustomer.gender = v == 0
                                    ? Gender.male
                                    : v == 1
                                        ? Gender.female
                                        : Gender.diverse;
                                setState(() => dropdownValue = v);
                                dirty = true;
                                changed = true;
                              }),
                          TextFormField(
                              initialValue: newCustomer.address,
                              maxLines: 1,
                              decoration: InputDecoration(labelText: 'Adresse'),
                              validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                              onChanged: (String input) {
                                newCustomer.address = input;
                                _formKey.currentState.validate();
                                dirty = true;
                                changed = true;
                              }),
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                      initialValue: newCustomer.zipCode?.toString() ?? '',
                                      maxLines: 1,
                                      decoration: InputDecoration(labelText: 'Postleitzahl'),
                                      keyboardType: TextInputType.numberWithOptions(),
                                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                                      onChanged: (String input) {
                                        newCustomer.zipCode = int.parse(input);
                                        _formKey.currentState.validate();
                                        dirty = true;
                                        changed = true;
                                      }),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                      initialValue: newCustomer.city,
                                      maxLines: 1,
                                      decoration: InputDecoration(labelText: 'Stadt'),
                                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                                      onChanged: (String input) {
                                        newCustomer.city = input;
                                        _formKey.currentState.validate();
                                        dirty = true;
                                        changed = true;
                                      }),
                                ),
                              ]),
                          TextFormField(
                            initialValue: newCustomer.country,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Land'),
                            onChanged: (String input) {
                              newCustomer.country = input;
                              dirty = true;
                              changed = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newCustomer.telephone,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Telefon'),
                            onChanged: (String input) {
                              newCustomer.telephone = input;
                              dirty = true;
                              changed = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newCustomer.fax,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Fax'),
                            onChanged: (String input) {
                              newCustomer.fax = input;
                              dirty = true;
                              changed = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newCustomer.mobile,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'Mobil'),
                            onChanged: (String input) {
                              newCustomer.mobile = input;
                              dirty = true;
                              changed = true;
                            },
                          ),
                          TextFormField(
                            initialValue: newCustomer.email,
                            maxLines: 1,
                            decoration: InputDecoration(labelText: 'E-Mail'),
                            validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                            onChanged: (String input) {
                              newCustomer.email = input;
                              _formKey.currentState.validate();
                              dirty = true;
                              changed = true;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
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

  void initDb() async {
    if (mounted) setState(() => busy = true);

    repo = CustomerRepository(InheritedDatabase.of(context));
    draftRepo = DraftRepository(InheritedDatabase.of(context));

    if (widget.id != null) {
      customer = await repo.selectSingle(widget.id);
      if (customer == null) {
        Navigator.pop(context);
        return null;
      }
      if (mounted) {
        setState(() {
          newCustomer = customer;
          dropdownValue = customer.gender.index;
        });
      }
    }

    if (mounted) setState(() => busy = false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.id == null) {
      newCustomer.gender = Gender.diverse;
      customer = newCustomer;
    }
  }

  void onDeleteCustomer() async {
    final result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Soll dieser Kunde wirlich gelöscht werden?'),
              actions: <Widget>[
                MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Behalten')),
                MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Löschen')),
              ],
            ));

    if (result == 1) {
      if (mounted) setState(() => busy = true);
      final customerDrafts =
          (await draftRepo.select()).where((Draft d) => d.customer == customer.id).toList();
      if (customerDrafts.isEmpty) {
        await repo.delete(widget.id);
        Navigator.pop(context, true);
      } else {
        final result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(
                'Es existieren noch ${customerDrafts.length} Rechnungsentwürfe für diesen Kunden. Sollen die Entwürfe auch gelöscht werden?'),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () => Navigator.pop(context, 0), child: Text('Alles behalten')),
              MaterialButton(
                  onPressed: () => Navigator.pop(context, 1), child: Text('Alles löschen')),
            ],
          ),
        );
        if (result == 1) {
          for (var draft in customerDrafts) {
            await draftRepo.delete(draft.id);
          }
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Verbleibende Rechnungsentwürfe wurden gelöscht.'),
            duration: Duration(seconds: 3),
          ));
          await repo.delete(widget.id);
          Navigator.pop(context, true);
        }
      }
      if (mounted) setState(() => busy = false);
    }
  }

  void onPopRoute() async {
    if (dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Es gibt möglicherweise ungespeicherte Änderungen an diesem Kunden. Vor dem Verlassen abspeichern?'),
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
          break;
        case 1:
          onSaveCustomer();
          break;
        default:
          return;
      }
    }

    Navigator.pop(context, changed);
  }

  void onSaveCustomer() async {
    if (mounted) setState(() => busy = true);
    if (_formKey.currentState.validate()) {
      if (widget.id != null) {
        await repo.update(newCustomer);
        customer = await repo.selectSingle(widget.id);
        setState(() => customer);
      } else {
        await repo.insert(newCustomer);
        Navigator.pop<bool>(context, true);
      }
      dirty = false;
    }
    if (mounted) setState(() => busy = false);
  }
}
