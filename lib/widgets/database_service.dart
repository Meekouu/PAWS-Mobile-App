import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://paws-clinic-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.set(data);
  }

  Future<DataSnapshot?> read({required String path}) async { //comi
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    final DataSnapshot snapshot = await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.update(data);
  }

  Future<void> delete({required String path}) async{
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.remove();
  }

    //check if filled up, if yes, skip onboard
    Future<bool> exists({required String path}) async {
    final snapshot = await read(path: path);
    return snapshot != null;
  }

  Stream<DatabaseEvent> stream(String path) {
  return _firebaseDatabase.ref().child(path).onValue;
}

Future<void> deletePetByName({required String uid, required String petName}) async {
  final petRef = _firebaseDatabase.ref().child('pet/$uid');
  final snapshot = await petRef.get();

  if (snapshot.exists) {
    final pets = snapshot.value as Map<dynamic, dynamic>;

    for (var entry in pets.entries) {
      final petId = entry.key;
      final petData = entry.value as Map<dynamic, dynamic>;

      if (petData['petName'] == petName) {
        await petRef.child(petId).remove();
        break;
      }
    }
  }
}


}





//DITO
// put async

// await DatabaseService().create(path: 'data1', data:{'name':'colt'});

// final snapshot = await DatabaseService().read(path: 'users/user001');
// if (snapshot.exists) {
//   print(snapshot.value);
// } else {
//   print('No data found.');
// }


// await DatabaseService().update(
//   path: 'users/user001',
//   data: {'age': 22}, // updates only the age field
// );

// await DatabaseService().delete(path: 'users/user001');

// DatabaseService().stream(path: 'users/user001').listen((event) {
//   final data = event.snapshot.value;
//   print("🔄 Updated data: $data");
// });



