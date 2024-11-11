import 'package:flutter/material.dart';

import '/src/models/bill.dart';

class BillIcon extends StatelessWidget {
  final Bill bill;

  const BillIcon({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        _buildBillIcon(),
        if (bill.reminders.isNotEmpty) ..._buildReminderIcons(),
      ],
    );
  }

  Widget _buildBillIcon() {
    switch (bill.status) {
      case BillStatus.unpaid:
        if (DateTime.now().isAfter(bill.dueDate)) {
          return Icon(Icons.euro_symbol, color: Colors.red);
        } else {
          return Icon(Icons.euro_symbol, color: Colors.orange);
        }
      case BillStatus.cancelled:
        return Icon(Icons.cancel, color: Colors.grey);
      case BillStatus.paid:
        return Icon(Icons.check, color: Colors.green);
      default:
        return Icon(Icons.euro_symbol, color: Colors.orange);
    }
  }

  List<Widget> _buildReminderIcons() {
    List<Widget> icons = [];
    for (var i = 0; i < bill.reminders.length; i++) {
      icons.add(
        Transform.translate(
          offset: Offset(18.0 - 7 * i, 14.0),
          child: Icon(
            Icons.notification_important,
            size: 18.0,
            color: ((i == (bill.reminders.length - 1)) &&
                    bill.status == BillStatus.paid)
                ? Colors.green
                : ((i == (bill.reminders.length - 1)) &&
                        DateTime.now().isBefore(bill.reminders[i].deadline))
                    ? Colors.orange
                    : Colors.red,
          ),
        ),
      );
    }

    return icons;
  }
}
