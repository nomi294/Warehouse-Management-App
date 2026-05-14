import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier.dart';

class FirebaseSupplierService {
  final CollectionReference suppliers =
  FirebaseFirestore.instance.collection("suppliers");

  Stream<List<Supplier>> getSuppliers() {
    return suppliers.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Supplier.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> addSupplier(Supplier s) => suppliers.add(s.toMap());
  Future<void> updateSupplier(Supplier s) =>
      suppliers.doc(s.id).update(s.toMap());
  Future<void> deleteSupplier(String id) =>
      suppliers.doc(id).delete();
}
