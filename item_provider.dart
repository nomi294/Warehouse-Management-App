import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firebase_item_service.dart';

class ItemProvider extends ChangeNotifier {
  final FirebaseItemService _service = FirebaseItemService();

  List<Item> _items = [];
  List<Item> get items => _items;
  List<Item> get lowStockItems => _items.where((item) => item.quantity <= 5).toList();

  ItemProvider() {
    _listenToItems();
  }

  void _listenToItems() {
    _service.getItems().listen((snapshot) {
      _items = snapshot;
      notifyListeners();
    });
  }

  Future<void> addItem(Item item) => _service.addItem(item);
  Future<void> updateItem(Item item) => _service.updateItem(item);
  Future<void> deleteItem(String id) => _service.deleteItem(id);

  List<Item> searchItems(String q) {
    q = q.toLowerCase();
    return _items.where((item) =>
    item.name.toLowerCase().contains(q) ||
        item.category.toLowerCase().contains(q)).toList();
  }
}
