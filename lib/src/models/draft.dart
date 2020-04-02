import 'dart:convert';

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

  factory Draft.empty() => Draft(
        billNr: null,
        customer: null,
        editor: null,
        items: <Item>[],
        tax: null,
        vendor: null,
      );

  factory Draft.fromMap(Map map) => Draft(
        billNr: map['bill_nr'].toString(),
        editor: map['editor'].toString(),
        customer: map['customer'] as int,
        vendor: map['vendor'] as int,
        items: ((json.decode(map['items'].toString()) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map))).toList(),
        tax: map['tax'] as int,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'bill_nr': billNr,
        'editor': editor,
        'customer': customer,
        'vendor': vendor,
        'items': json.encode(items.map((e) => e.toMap).toList()),
        'tax': tax,
      };

  @override
  String toString() => '[Draft $id $toMap]';
}
