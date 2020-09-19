import 'package:flutter/material.dart';

import '../../models/bill.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../widgets/shortcuts/bill_shortcut.dart';
import '../../widgets/navigation_card.dart';

class BillsNavigationCard extends StatefulWidget {
  @override
  _BillsNavigationCardState createState() => _BillsNavigationCardState();
}

class _BillsNavigationCardState extends State<BillsNavigationCard> {
  BillRepository _billRepo;
  List<Bill> _bills = [];

  @override
  Widget build(BuildContext context) {
    return NavigationCard(
      context,
      '/bills',
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text('Rechnungen',
                    style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis)),
            IconButton(
                tooltip: 'Aktualisieren',
                icon: Icon(Icons.refresh, color: Colors.grey[800]),
                onPressed: () => onGetBills())
          ],
        ),
        Divider(),
        Text('Neu', style: Theme.of(context).textTheme.headline4),
        Text(
            'In den letzten 7 Tagen wurden ${_bills.where((Bill b) => b.created.isAfter(DateTime.now().subtract(Duration(days: 7)))).length} Rechnungen erstellt',
            style: TextStyle(color: Colors.grey[800])),
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._bills.take(4).map<Widget>(
                  (Bill b) => Expanded(child: BillShortcut(context, bill: b)),
                ),
            if (_bills.length > 4)
              Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0)),
          ],
        )),
        Divider(height: 24.0),
        Text('Überfällig', style: Theme.of(context).textTheme.headline4),
        Text(
          ' Es gibt gerade ${_bills.where((Bill b) => (((b.reminders == null || b.reminders.isEmpty) && DateTime.now().isAfter(b.dueDate)) || (b.reminders != null && b.reminders.isNotEmpty && DateTime.now().isAfter(b.reminders.last.deadline))) && b.status == BillStatus.unpaid).length} überfällige Rechnungen oder zugehörige Mahnungen',
          style: TextStyle(color: Colors.grey[800]),
        ),
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._bills
                .where((Bill b) =>
                    (((b.reminders == null || b.reminders.isEmpty) &&
                            DateTime.now().isAfter(b.dueDate)) ||
                        (b.reminders != null &&
                            b.reminders.isNotEmpty &&
                            DateTime.now().isAfter(b.reminders.last.deadline))) &&
                    b.status == BillStatus.unpaid)
                .take(4)
                .map<Widget>(
                  (Bill b) => Expanded(child: BillShortcut(context, bill: b)),
                ),
            if (_bills.length > 4)
              Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0)),
          ],
        )),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    _billRepo = BillRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    await _billRepo.setUp();

    await onGetBills();
  }

  Future<void> onGetBills() async {
    _bills = await _billRepo.select();
    _bills.sort((Bill a, Bill b) => b.created.compareTo(a.created));
    if (mounted) setState(() => _bills);
    return;
  }
}
