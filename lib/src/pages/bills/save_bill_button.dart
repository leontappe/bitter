import 'package:flutter/material.dart';

import '../../models/bill.dart';
import '../../util.dart';

class SaveBillButton extends StatelessWidget {
  final Bill bill;

  const SaveBillButton({Key key, @required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Rechnung abspeichern',
      icon: Icon(Icons.file_download),
      onPressed: (bill != null) ? () => onSaveBill(context, bill.billNr, bill.file) : null,
    );
  }
}
