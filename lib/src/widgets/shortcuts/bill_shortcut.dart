import 'package:flutter/material.dart';

import '/src/models/bill.dart';
import '/src/pages/bills/bill_page.dart';
import '/src/util/format_util.dart';
import 'base_shortcut.dart';

class BillShortcut extends StatelessWidget {
  final BuildContext context;
  final Bill bill;
  final bool showVendor;

  const BillShortcut(
    this.context, {
    super.key,
    required this.bill,
    this.showVendor = true,
  });

  @override
  Widget build(BuildContext context) {
    return BaseShortcut(
      context,
      onTap: () => Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => BillPage(id: bill.id!))),
      children: <Widget>[
        Text(bill.billNr,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
            textScaleFactor: 1.1,
            overflow: TextOverflow.ellipsis),
        if (showVendor) Text(bill.vendor.name, overflow: TextOverflow.ellipsis),
        Text(bill.customer.fullCompany ?? bill.customer.fullName,
            overflow: TextOverflow.ellipsis),
        Text('${bill.items.length} Artikel', overflow: TextOverflow.ellipsis),
        Text(formatFigure(bill.sum) ?? '', overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
