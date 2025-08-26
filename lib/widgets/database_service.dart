import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> create({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(collectionPath).doc(docId).set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> read({
    required String collectionPath,
    required String docId,
  }) async {
    return await _db.collection(collectionPath).doc(docId).get();
  }

  Future<void> update({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(collectionPath).doc(docId).update(data);
  }

  Future<void> delete({
    required String collectionPath,
    required String docId,
  }) async {
    await _db.collection(collectionPath).doc(docId).delete();
  }

  Future<bool> exists({
    required String collectionPath,
    required String docId,
  }) async {
    final snapshot = await _db.collection(collectionPath).doc(docId).get();
    return snapshot.exists;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath,
  ) {
    return _db.collection(collectionPath).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument({
    required String collectionPath,
    required String docId,
  }) {
    return _db.collection(collectionPath).doc(docId).snapshots();
  }

  Future<void> deletePetByName({
    required String uid,
    required String petName,
  }) async {
    final petsRef = _db.collection('users').doc(uid).collection('pets');
    final snapshot = await petsRef.where('petName', isEqualTo: petName).get();

    for (var doc in snapshot.docs) {
      await petsRef.doc(doc.id).delete();
    }
  }
}
