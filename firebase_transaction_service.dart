// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class FirebaseTransactionService {
  final CollectionReference trans =
  FirebaseFirestore.instance.collection("transactions");

  Stream<List<WarehouseTransaction>> getTransactions() {
    return trans.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => WarehouseTransaction.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> addTransaction(WarehouseTransaction t) =>
      trans.add(t.toMap());

  Future<void> deleteTransaction(String id) =>
      trans.doc(id).delete();
}
