import 'dart:convert';

import 'package:meta/meta.dart';

import 'customer.dart';
import 'item.dart';
import 'vendor.dart';

enum BillStatus {
  unpaid,
  paid,
  cancelled,
}

class Bill {
  int id;

  final String billNr;
  final List<int> file;

  final DateTime created;
  final DateTime serviceDate;
  final DateTime dueDate;

  final int sum;
  final String editor;
  final Vendor vendor;
  final Customer customer;
  final List<Item> items;

  BillStatus status;
  String note;

  Bill({
    this.id,
    this.status = BillStatus.unpaid,
    @required this.billNr,
    @required this.file,
    @required this.sum,
    @required this.editor,
    @required this.vendor,
    @required this.customer,
    @required this.items,
    @required this.created,
    @required this.serviceDate,
    @required this.dueDate,
    this.note,
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
        dueDate: null,
        serviceDate: null,
      );

  factory Bill.fromMap(Map map) => Bill(
        id: map['id'] as int,
        status: _intToStatus(int.parse(map['status'].toString())),
        billNr: map['bill_nr'].toString(),
        file: base64.decode(map['file'].toString()),
        sum: int.parse(map['sum'].toString()),
        editor: map['editor'].toString(),
        vendor: Vendor.fromMap(json.decode(map['vendor'].toString()) as Map),
        customer: Customer.fromMap(json.decode(map['customer'].toString()) as Map),
        items: ((json.decode(map['items'].toString()) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map))).toList(),
        created: DateTime.parse(map['created'].toString()).toLocal(),
        serviceDate: DateTime.parse(map['service_date'].toString()).toLocal(),
        dueDate: DateTime.parse(map['due_date'].toString()).toLocal(),
        note: (map['note'] != null) ? map['note'].toString() : null,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'status': status.index,
        'bill_nr': billNr,
        'file': base64.encode(file),
        'sum': sum.toString(),
        'editor': editor,
        'vendor': json.encode(vendor.toMapLong),
        'customer': json.encode(customer.toMapLong),
        'items': json.encode(items.map((e) => e.toMap).toList()),
        'created': created.toUtc().toIso8601String(),
        'service_date': serviceDate.toUtc().toIso8601String(),
        'due_date': dueDate.toUtc().toIso8601String(),
        if (note != null) 'note': note,
      };

  @override
  String toString() => '[Bill $id $toMap]';

  static BillStatus _intToStatus(int i) {
    switch (i) {
      case 0:
        return BillStatus.unpaid;
      case 1:
        return BillStatus.paid;
      case 2:
        return BillStatus.cancelled;
      default:
        return BillStatus.unpaid;
    }
  }
}
