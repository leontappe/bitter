import 'dart:convert';

import 'item.dart';

class Commissioning {
  int id;
  final int vendorId;
  final int warehouseId;

  DateTime timestamp;
  List<Item> items;

  Commissioning({
    this.id,
    this.vendorId,
    this.warehouseId,
    this.timestamp,
    this.items = const <Item>[],
  });

  factory Commissioning.fromMap(Map map) => Commissioning(
        id: map['id'] as int,
        vendorId: map['vendor_id'] as int,
        warehouseId: map['warehouse_id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        items: List.from((json.decode(map['items'] as String) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map))),
      );

  int get sum {
    var sum = 0;
    for (var item in items) {
      sum += item.sum;
    }
    return sum;
  }

  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'vendor_id': vendorId,
        'warehouse_id': warehouseId,
        'timestamp': timestamp.toIso8601String(),
        'items': json.encode(items.map<Map>((Item i) => i.toMap).toList()),
      };

  @override
  String toString() => 'Commissioning [$toMap]';
}
