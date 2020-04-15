import 'dart:convert';

import 'package:meta/meta.dart';

import 'customer.dart';
import 'item.dart';
import 'vendor.dart';

class Bill {
  int id;

  final String billNr;
  final List<int> file;
  final DateTime created;

  final int sum;
  final String editor;
  final Vendor vendor;
  final Customer customer;
  final List<Item> items;

  Bill({
    this.id,
    @required this.billNr,
    @required this.file,
    @required this.sum,
    @required this.editor,
    @required this.vendor,
    @required this.customer,
    @required this.items,
    @required this.created,
  });

  factory Bill.empty() => Bill(
        billNr: null,
        file: null,
        sum: null,
        editor: null,
        vendor: null,
        customer: null,
        items: null,
        created: null,
      );

  factory Bill.fromMap(Map map) => Bill(
        id: map['id'] as int,
        billNr: map['bill_nr'].toString(),
        file: base64.decode(map['file'].toString()),
        sum: int.parse(map['sum'].toString()),
        editor: map['editor'].toString(),
        vendor: Vendor.fromMap(json.decode(map['vendor'].toString()) as Map),
        customer: Customer.fromMap(json.decode(map['customer'].toString()) as Map),
        items: ((json.decode(map['items'].toString()) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map))).toList(),
        created: DateTime.parse(map['created'].toString()).toLocal(),
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'bill_nr': billNr,
        'file': base64.encode(file),
        'sum': sum.toString(),
        'editor': editor,
        'vendor': json.encode(vendor.toMapLong),
        'customer': json.encode(customer.toMapLong),
        'items': json.encode(items.map((e) => e.toMap).toList()),
        'created': created.toUtc(),
      };

  @override
  String toString() => '[Bill $id $toMap]';
}
