import 'package:health_check/models/user.dart';
import 'package:health_check/repository/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository implements BaseRepository<User> {
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  @override
  Future<void> create(User user) async {
    user.touch(); // set createdAt/updatedAt
    await _usersRef.doc(user.id).set(user.toMap());
  }

  @override
  Future<User?> read(String id) async {
    final doc = await _usersRef.doc(id).get();
    if (!doc.exists) return null;
    return User.fromDocument(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> update(User user) async {
    user.touch(); // update updatedAt
    await _usersRef.doc(user.id).update(user.toMap());
  }

  @override
  Future<void> delete(String id) async {
    final doc = await _usersRef.doc(id).get();
    if (!doc.exists) return;

    // soft delete by updating deletedAt
    final user = User.fromDocument(doc.data() as Map<String, dynamic>);
    user.markDeleted();
    await _usersRef.doc(id).update(user.toMap());
  }

  @override
  Future<List<User>> getAll() async {
    final snapshot = await _usersRef.get();
    return snapshot.docs
        .map((doc) => User.fromDocument(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
