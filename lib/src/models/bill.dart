import 'package:meta/meta.dart';

import 'customer.dart';
import 'item.dart';

class Bill {
  int id;

  Customer customer;
  List<Item> items;

  int tax;

  int get sum {
    var sum = 0;
    for (var item in items) {
      sum += item.sum;
    }
    return sum;
  }

  Bill({this.id, @required this.customer, @required this.items, @required this.tax});

  factory Bill.fromMap(Map map) => Bill(
      customer: Customer.fromMap(map['customer'] as Map),
      items: map['items'] as List<Item>,
      tax: map['tax'] as int);

  Map<String, dynamic> get toMap =>
      <String, dynamic>{'customer': customer.toMap, 'items': items, 'tax': tax};

  @override
  String toString() => '[Bill $id $toMap]';
}
