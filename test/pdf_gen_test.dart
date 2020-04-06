import 'dart:io';

import 'package:bitter/src/bills/pdf_generator.dart';
import 'package:pdf/widgets.dart';

import 'example_data.dart';

void main() {
  final pdf = PdfGenerator();
  Document doc;

  final logo = File('test/logo.png');

  doc = pdf.createDocumentFromBill(
    'RE1',
    exampleBill,
    exampleCustomer,
    exampleVendor,
    rightHeader: logo.readAsBytesSync(),
  );

  var file = File('./test.pdf');

  file.writeAsBytesSync(doc.save());

  print(doc);
}
