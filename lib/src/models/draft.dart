import 'package:meta/meta.dart';

import 'item.dart';

class Draft {
  int id;

  String billNr;
  String editor;
  int customer;
  int vendor;
  List<Item> items;
  int tax;

  int get sum {
    var sum = 0;
    for (var item in items) {
      sum += item.sum;
    }
    return sum;
  }

  Draft({
    this.id,
    @required this.billNr,
    @required this.editor,
    @required this.customer,
    @required this.vendor,
    @required this.items,
    @required this.tax,
  });

  factory Draft.fromMap(Map map) => Draft(
        billNr: map['bill_nr'].toString(),
        editor: map['editor'].toString(),
        customer: map['customer'] as int,
        vendor: map['vendor'] as int,
        items: map['items'] as List<Item>,
        tax: map['tax'] as int,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'bill_nr': billNr,
        'editor': editor,
        'customer': customer,
        'vendor': vendor,
        'items': items,
        'tax': tax,
      };

  @override
  String toString() => '[Draft $id $toMap]';
}
