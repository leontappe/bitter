import 'package:flutter/material.dart';

import '/src/providers/inherited_database.dart';
import '/src/repositories/bill_repository.dart';
import '/src/util/ui_util.dart';

class SaveBillButton extends StatelessWidget {
  final int? billId;

  const SaveBillButton({this.billId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Rechnung abspeichern',
      icon: Icon(Icons.file_download),
      onPressed: (billId != null)
          ? () async {
              final bill = await BillRepository(InheritedDatabase.of(context))
                  .selectSingle(billId!);
              await onSaveBill(context, bill!.billNr, bill.file);
            }
          : null,
    );
  }
}
