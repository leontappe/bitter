import 'dart:convert';

import 'crate.dart';

class Warehouse {
  int id;
  int vendorId;

  String name;
  List<Crate> inventory;

  Warehouse({
    this.id,
    this.name,
    this.vendorId,
    this.inventory = const <Crate>[],
  });

  factory Warehouse.fromMap(Map map) => Warehouse(
        id: map['id'] as int,
        name: map['name'] as String,
        vendorId: map['vendor_id'] as int,
        inventory: List.from((json.decode(map['inventory'] as String) as List)
            .map<Crate>((dynamic map) => Crate.fromMap(map as Map))),
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'name': name,
        'vendor_id': vendorId,
        'inventory': json.encode(inventory.map((Crate c) => c.toMap).toList()),
      };
}
