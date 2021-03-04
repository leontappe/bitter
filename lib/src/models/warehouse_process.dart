import 'dart:convert';

import 'item.dart';

class GoodsIssue extends WarehouseProcess {
  Commission commission;

  GoodsIssue({
    int id,
    int vendorId,
    int warehouseId,
    DateTime timestamp,
    this.commission,
  }) : super(id: id, vendorId: vendorId, warehouseId: warehouseId, timestamp: timestamp);

  factory GoodsIssue.fromMap(Map map) => GoodsIssue(
        id: map['id'] as int,
        vendorId: map['vendor_id'] as int,
        warehouseId: map['warehouse_id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        commission: Commission.fromMap(json.decode(map['commission'] as String) as Map),
      );

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        ...super.toMap,
        'commission': json.encode(commission.toMap),
      };
}

class Commission extends WarehouseProcess {
  List<Item> items;

  Commission({
    int id,
    int vendorId,
    int warehouseId,
    DateTime timestamp,
    this.items,
  }) : super(id: id, vendorId: vendorId, warehouseId: warehouseId, timestamp: timestamp);

  factory Commission.fromMap(Map map) => Commission(
        id: map['id'] as int,
        vendorId: map['vendor_id'] as int,
        warehouseId: map['warehouse_id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        items: List.from((json.decode(map['items'] as String) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map))),
      );

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        ...super.toMap,
        'items': json.encode(items.map<Map>((Item i) => i.toMap).toList()),
      };
}

class GoodsReceipt extends WarehouseProcess {
  List<IncomingItem> items;

  GoodsReceipt({
    int id,
    int vendorId,
    int warehouseId,
    DateTime timestamp,
    this.items,
  }) : super(id: id, vendorId: vendorId, warehouseId: warehouseId, timestamp: timestamp);

  factory GoodsReceipt.fromMap(Map map) => GoodsReceipt(
      id: map['id'] as int,
      vendorId: map['vendor_id'] as int,
      warehouseId: map['warehouse_id'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      items: List.from((json.decode(map['items'] as String) as List)
          .map<IncomingItem>((dynamic e) => IncomingItem.fromMap(e as Map))));

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        ...super.toMap,
        'items': json.encode(List<Map>.from(items.map<Map>((IncomingItem i) => i.toMap))),
      };
}

class IncomingItem {
  int id;
  int itemId;

  int price;
  int tax;
  int quantity;

  IncomingItem({this.id, this.itemId, this.price, this.tax, this.quantity});

  factory IncomingItem.fromMap(Map map) => IncomingItem();

  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'item_id': itemId,
        'price': price,
        'tax': tax,
        'quantity': quantity,
      };
}

abstract class WarehouseProcess {
  int id;
  int vendorId;
  int warehouseId;
  DateTime timestamp;

  WarehouseProcess({this.id, this.vendorId, this.warehouseId, this.timestamp});

  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'vendor_id': vendorId,
        'warehouse_id': warehouseId,
        'timestamp': timestamp.toIso8601String(),
      };
}
