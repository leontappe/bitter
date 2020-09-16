import 'dart:io';

import 'package:bitter/src/pdf/pdf_generator.dart';
import 'package:pdf/widgets.dart';

import 'example_data.dart';

void main() async {
  final pdf = PdfGenerator();
  Document doc;

  final logo = File('test/logo.png');

  doc = await pdf.createDocumentFromBill(
    'RE1',
    exampleDraft,
    exampleCustomer,
    exampleVendor,
    rightHeader: logo.readAsBytesSync(),
  );

  var file = File('test/test.pdf');

  file.writeAsBytesSync(doc.save());

  print(doc);
}
