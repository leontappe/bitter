import 'dart:convert';

import 'customer.dart';
import 'item.dart';
import 'reminder.dart';
import 'vendor.dart';

class Bill {
  static final shortKeys = <String>[
    'id',
    'status',
    'bill_nr',
    'sum',
    'editor',
    'vendor',
    'customer',
    'items',
    'user_message',
    'comment',
    'created',
    'service_date',
    'due_date',
    'note',
    'reminders'
  ];

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
  final String userMessage;

  final String comment;
  BillStatus status;

  String note;

  List<Reminder> reminders;

  Bill({
    this.id,
    this.status = BillStatus.unpaid,
    required this.billNr,
    required this.file,
    required this.sum,
    required this.editor,
    required this.vendor,
    required this.customer,
    required this.items,
    this.userMessage,
    this.comment,
    required this.created,
    required this.serviceDate,
    required this.dueDate,
    this.note,
    this.reminders = const <Reminder>[],
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

  factory Bill.fromMap(Map<String, dynamic> map) => Bill(
        id: map['id'] as int,
        status: _intToStatus(int.parse(map['status'].toString())),
        billNr: map['bill_nr'].toString(),
        file: base64.decode(map['file'].toString()),
        sum: int.parse(map['sum'].toString()),
        editor: map['editor'].toString(),
        vendor: Vendor.fromMap(
            json.decode(map['vendor'].toString()) as Map<String, dynamic>),
        customer: Customer.fromMap(
            json.decode(map['customer'].toString()) as Map<String, dynamic>),
        items: ((json.decode(map['items'].toString()) as List).map<Item>(
                (dynamic map) => Item.fromMap(map as Map<String, dynamic>)))
            .toList(),
        userMessage: map['user_message']?.toString(),
        comment: map['comment']?.toString(),
        created: DateTime.parse(map['created'].toString()).toLocal(),
        serviceDate: DateTime.parse(map['service_date'].toString()).toLocal(),
        dueDate: DateTime.parse(map['due_date'].toString()).toLocal(),
        note: (map['note'] != null) ? map['note'].toString() : null,
        reminders: (map['reminders'] != null)
            ? List.from((json.decode(map['reminders'].toString()) as List)
                .map<Reminder>((dynamic map) =>
                    Reminder.fromMap(map as Map<String, dynamic>)))
            : <Reminder>[],
      );

  int get reminderSum =>
      sum +
      reminders.map((Reminder r) => r.fee).reduce((int a, int b) => a + b);

  Map<String, dynamic> get toMap => <String, dynamic>{
        ...toMapShort,
        'file': base64.encode(file),
      };

  Map<String, dynamic> get toMapShort => <String, dynamic>{
        'status': status.index,
        'bill_nr': billNr,
        'sum': sum.toString(),
        'editor': editor,
        'vendor': json.encode(vendor.toMapLong),
        'customer': json.encode(customer.toMapLong),
        'items': json.encode(items.map((e) => e.toMap).toList()),
        'user_message': userMessage,
        'comment': comment,
        'created': created.toUtc().toString(),
        'service_date': serviceDate.toUtc().toString(),
        'due_date': dueDate.toUtc().toString(),
        if (note != null) 'note': note,
        'reminders': json.encode(reminders.map((e) => e.toMap).toList())
      };

  @override
  String toString() => '[Bill $id $toMapShort]';

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

enum BillStatus {
  unpaid,
  paid,
  cancelled,
}
