import 'dart:convert';

import 'item.dart';

class Commissioning {
  int id;
  final int vendorId;

  final DateTime timestamp;
  final List<Item> items;

  Commissioning({this.id, this.vendorId, this.timestamp, this.items});

  factory Commissioning.fromMap(Map map) => Commissioning(
        id: map['id'] as int,
        vendorId: map['vendor_id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        items: List.from((json.decode(map['items'] as String) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map))),
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'vendor_id': vendorId,
        'timestamp': timestamp.toIso8601String(),
        'items': json.encode(items.map<Map>((Item i) => i.toMap)),
      };
}
