import 'package:firebase_database/firebase_database.dart';

class DatabaseService {

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.set(data);
  }

  Future<DataSnapshot?> read({required String path}) async {
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
}
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



  