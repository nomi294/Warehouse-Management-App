import '../models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class FirebaseItemService {
  final CollectionReference items =
  FirebaseFirestore.instance.collection("items");

  // Get all items
  Stream<List<Item>> getItems() {
    return items.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  // Add
  Future<void> addItem(Item item) {
    return items.add(item.toMap());
  }

  // Update
  Future<void> updateItem(Item item) {
    return items.doc(item.id).update(item.toMap());
  }

  // Delete
  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}
