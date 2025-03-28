abstract class ICollectionStorageService {
  Future<void> addToCollection(String key, dynamic value);
  Future<void> removeFromCollection(String key, dynamic value);
  Future<List<dynamic>> getCollection(String key, {List<dynamic> defaultValue});
  Future<void> clearCollection(String key);
}
