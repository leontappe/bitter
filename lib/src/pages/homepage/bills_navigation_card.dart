import 'package:flutter/material.dart';

import '../../providers/inherited_database.dart';
import '../../repositories/bill_repository.dart';
import '../../widgets/navigation_card.dart';
import '../../widgets/shortcuts/bill_shortcut.dart';

class BillsNavigationCard extends StatefulWidget {
  final int filter;

  BillsNavigationCard({this.filter = -1}) : super(key: Key(filter.toString()));

  @override
  _BillsNavigationCardState createState() => _BillsNavigationCardState();
}

class _BillsNavigationCardState extends State<BillsNavigationCard> {
  BillRepository _billRepo;
  List<Bill> _bills = [];

  List<Bill> get _overdueBills => _bills
      .where((Bill b) =>
          (((b.reminders == null || b.reminders.isEmpty) && DateTime.now().isAfter(b.dueDate)) ||
              (b.reminders != null &&
                  b.reminders.isNotEmpty &&
                  DateTime.now().isAfter(b.reminders.last.deadline))) &&
          b.status == BillStatus.unpaid)
      .toList();

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
                    style: Theme.of(context).textTheme.headline5, overflow: TextOverflow.ellipsis)),
            IconButton(
                tooltip: 'Aktualisieren',
                icon: Icon(Icons.refresh, color: Colors.grey[800]),
                onPressed: () => onGetBills())
          ],
        ),
        Divider(),
        Text('Neu', style: Theme.of(context).textTheme.headlineSmall),
        Text(
            'In den letzten 7 Tagen wurde${_bills.length == 1 ? '' : 'n'} ${_bills.where((Bill b) => b.created.isAfter(DateTime.now().subtract(Duration(days: 7)))).length} Rechnung${_bills.length == 1 ? '' : 'en'} erstellt.',
            style: TextStyle(color: Colors.grey[800])),
        if (_bills.isNotEmpty)
          Flexible(
              child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  height: (widget.filter != null && widget.filter > 0) ? 93.0 : 109.0, width: 0.0),
              ..._bills.take(4).map<Widget>(
                    (Bill b) => Expanded(
                        child: BillShortcut(context, bill: b, showVendor: widget.filter == null)),
                  ),
              if (_bills.length > 4)
                Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0))
              else if (_bills.isNotEmpty)
                Container(width: 48.0, height: 48.0),
              for (var i = 0; i < (4 - _bills.length); i++) Spacer(),
            ],
          )),
        /* if (_overdueBills.isNotEmpty)
          Column(
            children: [
              Divider(height: 24.0),
              Text('Überfällig', style: Theme.of(context).textTheme.headlineSmall),
              Text(
                'Es gibt gerade ${_overdueBills.length} überfällige Rechnung${_overdueBills.length == 1 ? '' : 'en'} oder zugehörige Mahnung${_overdueBills.length == 1 ? '' : 'en'}.',
                style: TextStyle(color: Colors.grey[800]),
                overflow: TextOverflow.ellipsis,
              ),
              Flexible(
                  child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: (widget.filter != null && widget.filter > 0) ? 93.0 : 109.0,
                      width: 0.0),
                  ..._overdueBills.take(4).map<Widget>(
                        (Bill b) => Expanded(
                            child:
                                BillShortcut(context, bill: b, showVendor: widget.filter == null)),
                      ),
                  if (_overdueBills.length > 4)
                    Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0)),
                  for (var i = 0; i < (4 - _overdueBills.length); i++) Spacer(),
                ],
              ))
            ],
          ), */
      ],
    );
  }

  Future<void> initDb() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    _billRepo = BillRepository(InheritedDatabase.of(context));

    try {
      await _billRepo.setUp();
      await onGetBills();
    } on NoSuchMethodError {
      print('db not available');
      return;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> onGetBills() async {
    _bills = await _billRepo.select(short: true);
    if (widget.filter != null && widget.filter > 0) {
      _bills.removeWhere((Bill b) => b.vendor.id != widget.filter);
    }
    _bills.sort((Bill a, Bill b) => b.created.compareTo(a.created));
    if (mounted) setState(() => _bills);
  }
}
