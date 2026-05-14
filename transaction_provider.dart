import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/firebase_transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseTransactionService _service = FirebaseTransactionService();

  List<WarehouseTransaction> _transactions = [];
  List<WarehouseTransaction> get transactions => _transactions;

  TransactionProvider() {
    _listenToTransactions();
  }

  void _listenToTransactions() {
    _service.getTransactions().listen((list) {
      _transactions = list;
      notifyListeners();
    });
  }

  Future<void> addTransaction(WarehouseTransaction t) =>
      _service.addTransaction(t);

  Future<void> deleteTransaction(String id) =>
      _service.deleteTransaction(id);
}
