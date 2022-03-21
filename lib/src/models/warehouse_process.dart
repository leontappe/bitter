import 'dart:convert';

import 'item.dart';

class GoodsIssue extends WarehouseProcess {
  Picking picking;
  IssueType type;

  GoodsIssue({
    int id,
    int vendorId,
    int warehouseId,
    DateTime timestamp,
    this.picking,
    this.type,
  }) : super(id: id, vendorId: vendorId, warehouseId: warehouseId, timestamp: timestamp);

  factory GoodsIssue.fromMap(Map<String, dynamic> map) => GoodsIssue(
        id: map['id'] as int,
        vendorId: map['vendor_id'] as int,
        warehouseId: map['warehouse_id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        picking: Picking.fromMap(json.decode(map['picking'] as String) as Map<String, dynamic>),
        type: IssueType.values[map['type'] as int],
      );

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        ...super.toMap,
        'picking': json.encode(picking.toMap),
        'type': type.index,
      };
}

class GoodsReceipt extends WarehouseProcess {
  List<IncomingItem> items;
  ReceiptType type;

  GoodsReceipt({
    int id,
    int vendorId,
    int warehouseId,
    DateTime timestamp,
    this.items,
    this.type,
  }) : super(id: id, vendorId: vendorId, warehouseId: warehouseId, timestamp: timestamp);

  factory GoodsReceipt.fromMap(Map<String, dynamic> map) => GoodsReceipt(
        id: map['id'] as int,
        vendorId: map['vendor_id'] as int,
        warehouseId: map['warehouse_id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        items: List.from((json.decode(map['items'] as String) as List)
            .map<IncomingItem>((dynamic e) => IncomingItem.fromMap(e as Map<String, dynamic>))),
        type: ReceiptType.values[map['type'] as int],
      );

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        ...super.toMap,
        'items': json.encode(List<Map<String, dynamic>>.from(
            items.map<Map<String, dynamic>>((IncomingItem i) => i.toMap))),
        'type': type.index,
      };
}

class IncomingItem {
  int id;
  int itemId;

  int price;
  int tax;
  int quantity;

  IncomingItem({this.id, this.itemId, this.price, this.tax, this.quantity});

  factory IncomingItem.fromMap(Map<String, dynamic> map) => IncomingItem();

  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'item_id': itemId,
        'price': price,
        'tax': tax,
        'quantity': quantity,
      };
}

enum IssueType {
  issue,
  shipping,
  transfer,
}

class Picking extends WarehouseProcess {
  List<Item> items;

  Picking({
    int id,
    int vendorId,
    int warehouseId,
    DateTime timestamp,
    this.items,
  }) : super(id: id, vendorId: vendorId, warehouseId: warehouseId, timestamp: timestamp);

  factory Picking.fromMap(Map<String, dynamic> map) => Picking(
        id: map['id'] as int,
        vendorId: map['vendor_id'] as int,
        warehouseId: map['warehouse_id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        items: List.from((json.decode(map['items'] as String) as List)
            .map<Item>((dynamic map) => Item.fromMap(map as Map<String, dynamic>))),
      );

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        ...super.toMap,
        'items': json.encode(items.map<Map<String, dynamic>>((Item i) => i.toMap).toList()),
      };
}

enum ReceiptType {
  receipt,
  returned,
  transfer,
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
