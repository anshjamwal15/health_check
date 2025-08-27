import 'package:health_check/models/base_model.dart';

class User extends BaseModel {
  final String id;
  String name;
  String email;
  String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  /// Setter that auto-updates `updatedAt`
  set updateName(String newName) {
    name = newName;
    touch(); // updates updatedAt
  }

  set updateEmail(String newEmail) {
    email = newEmail;
    touch();
  }

  set updatePhoneNumber(String newNumber) {
    phoneNumber = newNumber;
    touch();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      ...super.toMap(), // adds created_at, updated_at, deleted_at
    };
  }

  /// Create User from a Map (Firestore or local)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phone_number'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'])
          : null,
    );
  }

  /// Create User from Firestore Document
  factory User.fromDocument(Map<String, dynamic> doc) {
    return User.fromMap(doc);
  }
}
