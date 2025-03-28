abstract class IStorageService {
  Future<void> save(String key, dynamic value);
  Future<dynamic> get(String key, {dynamic defaultValue});
  Future<void> delete(String key);
  Future<void> clear();
  Future<void> close();
}
