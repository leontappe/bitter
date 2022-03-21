import 'dart:typed_data';

import 'package:pdf/widgets.dart';

import '../../fonts/liberation_sans.dart';
import '../../fonts/liberation_sans_bold.dart';
import '../models/item.dart';

int calculateTaxes(List<Item> items, int tax) {
  var result = 0;
  for (var item in items) {
    result += (((item.price * item.quantity) -
            ((item.price * item.quantity) / (1 + ((item.tax ?? tax) / 100)))))
        .round();
  }
  return result;
}

Font getTtfSans() {
  final sansData = ByteData(liberationSans.length);
  for (var i = 0; i < liberationSans.length; i++) {
    sansData.setUint8(i, liberationSans[i]);
  }
  return Font.ttf(sansData);
}

Font getTtfSansBold() {
  final sansBoldData = ByteData(liberationSansBold.length);
  for (var i = 0; i < liberationSansBold.length; i++) {
    sansBoldData.setUint8(i, liberationSansBold[i]);
  }
  return Font.ttf(sansBoldData);
}
