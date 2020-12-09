import 'dart:io';

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
      onPressed: (bill != null) ? () => onSaveBill(context) : null,
    );
  }

  Future<void> onSaveBill(BuildContext context) async {
    final file = File('${await getDataPath()}/${bill.billNr}.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(bill.file);
    await ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Die Rechnung wurde erfolgreich unter ${file.path} abgespeichert.'),
      duration: const Duration(seconds: 5),
    ));
  }
}
