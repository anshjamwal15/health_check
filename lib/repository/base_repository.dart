import 'package:health_check/models/base_model.dart';

abstract class BaseRepository<T extends BaseModel> {
  Future<void> create(T item);
  Future<T?> read(String id);
  Future<void> update(T item);
  Future<void> delete(String id);
  Future<List<T>> getAll();
}
