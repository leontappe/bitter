import 'dart:convert';



import 'item.dart';

class Draft {
  int id;

  String editor;
  int customer;
  int vendor;
  List<Item> items;
  int tax;

  DateTime serviceDate;
  int dueDays;

  String userMessage;
  String comment;

  Draft({
    this.id,
    required this.editor,
    required this.customer,
    required this.vendor,
    required this.items,
    required this.tax,
    required this.serviceDate,
    required this.dueDays,
    this.userMessage,
    this.comment,
  });

  factory Draft.empty() => Draft(
        customer: null,
        editor: null,
        items: <Item>[],
        tax: null,
        vendor: null,
        serviceDate: null,
        dueDays: null,
      );

  factory Draft.fromMap(Map<String, dynamic> map) => Draft(
        id: map['id'] as int,
        editor: map['editor'].toString(),
        customer: map['customer'] as int,
        vendor: map['vendor'] as int,
        items: ((json.decode(map['items'].toString()) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map<String, dynamic>))).toList(),
        tax: map['tax'] as int,
        serviceDate:
            (map['service_date'] != null) ? DateTime.parse(map['service_date'].toString()) : null,
        dueDays: int.parse(map['due_days'].toString()),
        userMessage: (map['user_message'] != null) ? map['user_message'].toString() : null,
        comment: map['comment']?.toString(),
      );

  int get sum {
    var sum = 0;
    for (var item in items) {
      sum += item.sum;
    }
    return sum;
  }

  Map<String, dynamic> get toMap => <String, dynamic>{
        'editor': editor,
        'customer': customer,
        'vendor': vendor,
        'items': json.encode(items.map((e) => e.toMap).toList()),
        'tax': tax,
        'service_date': serviceDate?.toString(),
        'due_days': dueDays,
        'user_message': userMessage,
        'comment': comment,
      };

  @override
  String toString() => '[Draft $id $toMap]';
}
