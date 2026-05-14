import 'package:flutter/material.dart';
import '../services/firebase_supplier_service.dart';
import '../models/supplier.dart';

class SupplierProvider extends ChangeNotifier {
  final FirebaseSupplierService _service = FirebaseSupplierService();

  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  SupplierProvider() {
    _listenToSuppliers();
  }

  void _listenToSuppliers() {
    _service.getSuppliers().listen((snapshot) {
      _suppliers = snapshot;
      notifyListeners();
    });
  }

  Future<void> addSupplier(Supplier s) => _service.addSupplier(s);
  Future<void> updateSupplier(Supplier s) => _service.updateSupplier(s);
  Future<void> deleteSupplier(String id) => _service.deleteSupplier(id);

  List<Supplier> searchSuppliers(String query) {
    query = query.toLowerCase();
    return _suppliers.where((s) =>
    s.name.toLowerCase().contains(query) ||
        s.company.toLowerCase().contains(query)).toList();
  }
}
