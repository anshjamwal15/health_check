abstract class BaseModel {
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  BaseModel({DateTime? createdAt, DateTime? updatedAt, this.deletedAt})
    : createdAt = createdAt ?? DateTime.now(),
      updatedAt = updatedAt ?? DateTime.now();

  void touch() {
    updatedAt = DateTime.now();
  }

  void markDeleted() {
    deletedAt = DateTime.now();
    touch();
  }

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Restore model from Map (for reading from Firestore/DB)
  BaseModel.fromMap(Map<String, dynamic> map)
    : createdAt = map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt = map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      deletedAt = map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'])
          : null;
}
