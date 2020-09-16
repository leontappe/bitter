import 'dart:io';

import 'package:bitter/src/pdf/reminder_generator.dart';
import 'package:pdf/widgets.dart';

import 'example_data.dart';

void main() async {
  final pdf = ReminderGenerator();
  Document doc;

  final logo = File('test/logo.png');

  doc = await pdf.createDocumentFromBill(
    exampleBill,
    exampleVendor,
    exampleReminder,
    rightHeader: logo.readAsBytesSync(),
  );

  var file = File('test/test_reminder.pdf');

  file.writeAsBytesSync(doc.save());

  print(doc);
}
