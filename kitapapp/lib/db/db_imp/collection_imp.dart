import 'package:kitapapp/db/collection.dart';
import 'package:kitapapp/db/storage.dart';

class HiveCollectionService implements ICollectionStorageService {
  final IStorageService _storageService;

  HiveCollectionService(this._storageService);

  @override
  Future<void> addToCollection(String key, dynamic value) async {
    // Koleksiyonu al
    final collection = await getCollection(key);

    // Koleksiyonun bir kopyasını oluştur (değiştirilebilir liste olarak)
    List<dynamic> modifiableCollection = List<dynamic>.from(collection);

    // Eğer değer koleksiyonda yoksa, kopyaya ekle
    if (!modifiableCollection.contains(value)) {
      modifiableCollection.add(value);

      // Güncellenmiş koleksiyonu kaydet
      await _storageService.save(key, modifiableCollection);
    }
  }

  @override
  Future<void> removeFromCollection(String key, dynamic value) async {
    final collection = await getCollection(key);

    collection.removeWhere((item) => item.toString() == value.toString());

    await _storageService.save(key, collection);
  }

  @override
  Future<List<dynamic>> getCollection(String key, {List<dynamic> defaultValue = const []}) async {
    final data = await _storageService.get(key, defaultValue: defaultValue);

    if (data is! List) {
      return data != null ? [data] : [];
    }

    return data;
  }

  @override
  Future<void> clearCollection(String key) async {
    await _storageService.save(key, <dynamic>[]);
  }
}
