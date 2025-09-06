import 'package:health_check/models/base_model.dart';
import 'package:health_check/states/app_state.dart';

class User extends BaseModel {
  final String id;
  String name;
  String email;
  String photoUrl;
  AppStatus appStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.appStatus = AppStatus.unknown,
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

  set updatePhotoUrl(String newPhotoUrl) {
    photoUrl = newPhotoUrl;
    touch();
  }

  set updateAppStatus(AppStatus newStatus) {
    appStatus = newStatus;
    touch();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': photoUrl,
      'app_status': appStatus.name, // save enum as string
      ...super.toMap(), // adds created_at, updated_at, deleted_at
    };
  }

  /// Create User from a Map (Firestore or local)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['phone_number'] ?? '',
      appStatus: _mapToAppStatus(map['app_status']),
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

  /// Helper to safely map String to Enum
  static AppStatus _mapToAppStatus(dynamic value) {
    if (value == null) return AppStatus.unknown;
    return AppStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppStatus.unknown,
    );
  }

  /// Create User from Firestore Document
  factory User.fromDocument(Map<String, dynamic> doc) {
    return User.fromMap(doc);
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    AppStatus? appStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      appStatus: appStatus ?? this.appStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
