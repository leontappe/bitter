import 'dart:io';

import 'package:bitter/src/pdf/pdf_generator.dart';
import 'package:pdf/widgets.dart';

import 'example_data.dart';

void main() async {
  final pdf = PdfGenerator();
  Document doc;

  final logo = File('test/logo.png');

  doc = await pdf.createDocumentFromBill(
    exampleDraft,
    exampleCustomer,
    exampleVendor,
    billNr: 'RE1',
    rightHeader: logo.readAsBytesSync(),
  );

  var file = File('test/test.pdf');

  file.writeAsBytesSync(doc.save());

  doc = await pdf.createDocumentFromBill(
    exampleDraft,
    exampleCustomer,
    exampleVendor,
    title: 'Vorschau',
    letter: 'zahl mal das hier:',
    rightHeader: logo.readAsBytesSync(),
  );

  var previewFile = File('test/test_preview.pdf');

  previewFile.writeAsBytesSync(doc.save());
}
