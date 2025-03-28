import 'package:kitapapp/db/collection.dart';
import 'package:kitapapp/db/db_imp/collection_imp.dart';
import 'package:kitapapp/db/db_imp/crud_imp.dart';
import 'package:kitapapp/db/favori_books.dart';
import 'package:kitapapp/db/storage.dart';

class StorageServiceFactory {
  static final StorageServiceFactory _instance =
      StorageServiceFactory._internal();

  final Map<String, IStorageService> _boxServices = {};
  final Map<String, ICollectionStorageService> _collectionServices = {};
  final Map<String, FavoriteBooksService> _favoriteServices = {};

  StorageServiceFactory._internal();

  factory StorageServiceFactory() {
    return _instance;
  }

  IStorageService getBoxService(String boxName) {
    if (!_boxServices.containsKey(boxName)) {
      _boxServices[boxName] = HiveBoxService(boxName);
    }
    return _boxServices[boxName]!;
  }

  ICollectionStorageService getCollectionService(String boxName) {
    if (!_collectionServices.containsKey(boxName)) {
      _collectionServices[boxName] =
          HiveCollectionService(getBoxService(boxName));
    }
    return _collectionServices[boxName]!;
  }

  FavoriteBooksService getFavoriteBooksService(String boxName,
      {String collectionKey = 'favoriteBooks'}) {
    final key = '$boxName:$collectionKey';
    if (!_favoriteServices.containsKey(key)) {
      _favoriteServices[key] = FavoriteBooksService(
          getCollectionService(boxName),
          collectionKey: collectionKey);
    }
    return _favoriteServices[key]!;
  }

  Future<void> closeAll() async {
    for (var service in _boxServices.values) {
      await service.close();
    }
    _boxServices.clear();
    _collectionServices.clear();
    _favoriteServices.clear();
  }
}
