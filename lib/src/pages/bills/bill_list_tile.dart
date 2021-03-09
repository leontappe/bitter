import 'package:flutter/material.dart';

import '../../models/bill.dart';
import '../../util/format_util.dart';
import 'bill_icon.dart';
import 'save_bill_button.dart';

class BillListTile extends StatelessWidget {
  final Bill bill;
  final Function() onTap;

  BillListTile({this.bill, this.onTap}) : super(key: Key(bill.id.toString()));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: BillIcon(bill: bill),
      title: Text(bill.billNr),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Bearbeiter*in: ${bill.editor}, ${bill.vendor.name} - Kunde*in: ${bill.customer.fullCompany ?? bill.customer.fullName}'),
          Text(
              'Rechnungsdatum: ${formatDate(bill.created)} - Leistungsdatum: ${formatDate(bill.serviceDate)} - Zahlungsziel: ${formatDate(bill.dueDate)}')
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
              child: Text(formatFigure(bill.sum),
                  style: Theme.of(context).textTheme.headline6,
                  textScaleFactor: 0.9,
                  overflow: TextOverflow.ellipsis)),
          SaveBillButton(billId: bill.id),
        ],
      ),
      onTap: onTap,
    );
  }
}
