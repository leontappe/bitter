import 'package:flutter/material.dart';

import '../../models/bill.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../widgets/bill_shortcut.dart';
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
        Text('Rechnungen', style: Theme.of(context).textTheme.headline3),
        Divider(height: 24.0),
        Text('Neu', style: Theme.of(context).textTheme.headline4),
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
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._bills
                .where((Bill b) =>
                    ((b.reminders == null || b.reminders.isEmpty) &&
                        DateTime.now().isAfter(b.dueDate)) ||
                    (b.reminders != null &&
                        b.reminders.isNotEmpty &&
                        DateTime.now().isAfter(b.reminders.last.deadline)))
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
    setState(() => _bills);
    return;
  }
}
