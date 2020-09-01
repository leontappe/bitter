import 'package:flutter/material.dart';

import '../../models/bill.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../widgets/customer_card.dart';
import '../../widgets/items_card.dart';
import '../../widgets/vendor_card.dart';
import 'save_bill_button.dart';

class BillPage extends StatefulWidget {
  final int id;

  BillPage({this.id});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BillRepository repo;

  Bill bill;

  bool dirty = false;

  @override
  Widget build(BuildContext context) {
    return (bill != null)
        ? Scaffold(
            appBar: AppBar(
              leading: Builder(
                  builder: (BuildContext context) => IconButton(
                        tooltip: 'Zurück',
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () => onPopRoute(context),
                      )),
              title: Text(bill.billNr),
              actions: [
                IconButton(icon: Icon(Icons.save), onPressed: onSaveBill),
                SaveBillButton(bill: bill),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(bill.billNr, style: Theme.of(context).textTheme.headline6),
                    subtitle:
                        Text('Erstellt am ${bill.created.toLocal().toString().split('.').first}'),
                    trailing: Text('von ${bill.editor}'),
                  ),
                  if (bill.userMessage != null)
                    ListTile(
                      title: Text((bill.vendor.userMessageLabel ??
                              'Benutzerdefinierter Rechnungskommentar') +
                          ': ${bill.userMessage}'),
                    ),
                  if (bill.comment != null)
                    ListTile(title: Text('Rechnungskommentar: ${bill.comment}')),
                  ListTile(
                    title: DropdownButton<BillStatus>(
                      style: Theme.of(context).textTheme.headline6,
                      isExpanded: false,
                      hint: Text('${bill?.status ?? BillStatus.unpaid}'),
                      value: bill?.status ?? BillStatus.unpaid,
                      items: [
                        DropdownMenuItem(value: BillStatus.unpaid, child: Text('Unbezahlt')),
                        DropdownMenuItem(value: BillStatus.paid, child: Text('Bezahlt')),
                        DropdownMenuItem(value: BillStatus.cancelled, child: Text('Storniert')),
                      ],
                      onChanged: (BillStatus v) {
                        setState(() => bill.status = v);
                        dirty = true;
                      },
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bill != null)
                          Text(
                              'Lieferdatum/Leistungsdatum: ${bill.serviceDate.day}.${bill.serviceDate.month}.${bill.serviceDate.year}'),
                        if (bill != null)
                          Text(
                              'Zahlungsziel: ${bill.dueDate.day}.${bill.dueDate.month}.${bill.dueDate.year}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'Notizen'),
                      initialValue: bill?.note ?? '',
                      onChanged: (String input) {
                        setState(() => bill.note = input);
                        dirty = true;
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Verkäufer', style: Theme.of(context).textTheme.headline6),
                    subtitle: VendorCard(vendor: bill.vendor),
                  ),
                  ListTile(
                    title: Text('Kunde', style: Theme.of(context).textTheme.headline6),
                    subtitle: CustomerCard(customer: bill.customer),
                  ),
                  ListTile(
                    title: Text('Artikel', style: Theme.of(context).textTheme.headline6),
                    subtitle: ItemsCard(items: bill.items, sum: bill.sum),
                  ),
                ],
              ),
            ),
          )
        : Container(width: 0.0, height: 0.0);
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = BillRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);

    bill = await repo.selectSingle(widget.id);

    setState(() => bill);
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
          if (!await onSaveBill()) {
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

  Future<bool> onSaveBill() async {
    if (_formKey.currentState.validate()) {
      await repo.update(bill);
      dirty = false;
      return true;
    }
    return false;
  }
}
