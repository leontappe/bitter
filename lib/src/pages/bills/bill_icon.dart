import 'package:flutter/material.dart';

import '../../models/bill.dart';

class BillIcon extends StatelessWidget {
  final Bill bill;

  const BillIcon({Key key, required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        (bill.status == BillStatus.unpaid && DateTime.now().isAfter(bill.dueDate))
            ? Icon(Icons.euro_symbol, color: Colors.red)
            : (bill.status == BillStatus.cancelled)
                ? Icon(Icons.cancel, color: Colors.red)
                : (bill.status == BillStatus.paid)
                    ? Icon(Icons.check, color: Colors.green)
                    : Icon(Icons.euro_symbol, color: Colors.orange),
        if (bill.reminders != null && bill.reminders.isNotEmpty)
          for (var i = 0; i < bill.reminders.length; i++)
            Transform.translate(
                offset: Offset(18.0 - 7 * i, 14.0),
                child: Icon(Icons.notification_important,
                    size: 18.0,
                    color: ((i == (bill.reminders.length - 1)) && bill.status == BillStatus.paid)
                        ? Colors.green
                        : ((i == (bill.reminders.length - 1)) &&
                                DateTime.now().isBefore(bill.reminders[i].deadline))
                            ? Colors.orange
                            : Colors.red)),
      ],
    );
  }
}
