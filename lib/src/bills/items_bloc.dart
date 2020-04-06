import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';

import '../models/item.dart';

class AddItem extends ItemsEvent {
  final Item item;

  AddItem(this.item);

  @override
  String toString() => '[AddItem $item]';
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
    print(event);

    if (event is AddItem) {
      event.item.id ??= sha256
          .convert(utf8.encode('${event.item.title} + ${DateTime.now().toString()}'))
          .toString();
      _items.add(event.item);
    } else if (event is RemoveItem) {
      _items.removeWhere((Item item) => item.id == event.id);
    } else if (event is UpdateItem) {
      _items[_items.indexWhere((Item item) => item.id == event.item.id)] = event.item;
    }

    yield ItemsState(_items);
  }

  void onAddItem(Item item) => add(AddItem(item));

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
