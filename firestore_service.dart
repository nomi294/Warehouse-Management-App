import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveScannedProduct(Map<String, dynamic> data) async {
    // Put into collection 'scanned_products' with auto ID
    await _db.collection('scanned_products').add({
      ...data,
      'saved_at': FieldValue.serverTimestamp(),
    });
  }
}
