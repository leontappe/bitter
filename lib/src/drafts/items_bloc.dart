import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';

import '../models/item.dart';

export '../models/item.dart';

class AddItem extends ItemsEvent {
  final Item item;

  AddItem(this.item);

  @override
  String toString() => '[AddItem $item]';
}

class BulkAdd extends ItemsEvent {
  final List<Item> items;

  BulkAdd(this.items);

  @override
  String toString() => '[BulkAdd $items]';
}

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  List<Item> _items;

  ItemsBloc() {
    _items = <Item>[];
  }

  @override
  ItemsState get initialState => ItemsState(const <Item>[]);

  List<Item> get items => _items;

  @override
  Stream<ItemsState> mapEventToState(ItemsEvent event) async* {
    if (event is AddItem) {
      event.item.id ??= sha256
          .convert(utf8.encode(
              '${event.item.title}${DateTime.now().toString()}${Random().nextInt(1024).toString()}'))
          .toString();
      _items.add(event.item);
    } else if (event is RemoveItem) {
      _items.removeWhere((Item item) => item.id == event.id);
    } else if (event is UpdateItem) {
      _items[_items.indexWhere((Item item) => item.id == event.item.id)] = event.item;
    } else if (event is BulkAdd) {
      for (var item in event.items) {
        add(AddItem(item));
      }
    }

    yield ItemsState(_items);
  }

  void onAddItem(Item item) => add(AddItem(item));

  void onBulkAdd(List<Item> items) => add(BulkAdd(items));

  void onRemoveItem(String id) => add(RemoveItem(id));

  void onUpdateItem(Item item) => add(UpdateItem(item));
}

abstract class ItemsEvent {}

class ItemsState {
  final List<Item> items;

  ItemsState(this.items);

  @override
  String toString() => '[ItemsState $items]';
}

class RemoveItem extends ItemsEvent {
  final String id;

  RemoveItem(this.id);

  @override
  String toString() => '[RemoveItem $id]';
}

class UpdateItem extends ItemsEvent {
  final Item item;

  UpdateItem(this.item);

  @override
  String toString() => '[UpdateItem $item]';
}
