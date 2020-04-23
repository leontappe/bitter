import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/bill.dart';

class SaveBillButton extends StatelessWidget {
  final Bill bill;

  const SaveBillButton({Key key, @required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Rechnung abspeichern',
      icon: Icon(Icons.file_download),
      onPressed: onSaveBill,
    );
  }

  Future<void> onSaveBill() async {
    String downloadsPath;
    if (Platform.isWindows) {
      downloadsPath = (await getApplicationDocumentsDirectory()).path;
    } else {
      downloadsPath = (await getDownloadsDirectory()).path;
    }
    final file = File('${downloadsPath}/bitter/${bill.billNr}.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(bill.file);
  }
}
