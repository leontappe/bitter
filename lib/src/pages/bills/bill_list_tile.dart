import 'package:flutter/material.dart';

import '../../models/bill.dart';
import '../../util.dart';
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
      trailing: SaveBillButton(bill: bill),
      onTap: onTap,
    );
  }
}