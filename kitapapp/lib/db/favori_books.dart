import 'package:hive/hive.dart';
import 'package:kitapapp/db/collection.dart';
import 'package:kitapapp/db/store_factory.dart';
import 'package:kitapapp/main.dart';
import 'package:kitapapp/models/actions.dart';
import 'package:kitapapp/models/api_model.dart';
import 'package:kitapapp/services/services_imp/repo_services_impl.dart';

class FavoriteBooksService {
  final ICollectionStorageService _collectionService;

  final String collectionKey;

  static final FavoriteBooksService _instance = FavoriteBooksService._internal();

  FavoriteBooksService(this._collectionService, {this.collectionKey = 'favoriteBooks'});

  factory FavoriteBooksService.create() {
    final collectionService = StorageServiceFactory().getCollectionService('favoritesBooks');

    return FavoriteBooksService(collectionService);
  }

  factory FavoriteBooksService.instance() {
    return _instance;
  }

  FavoriteBooksService._internal()
      : _collectionService = StorageServiceFactory().getCollectionService('favoritesBooks'),
        collectionKey = 'favoriteBooks';

  Future<void> addFavorite(String bookId) async {
    try {
      await _collectionService.addToCollection(collectionKey, bookId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadFavoritesFromHive() async {
    BookRepository repository = BookRepository();

    try {
      final hiveFavorites = await repository.getFavoriteBooks();

      final hiveFavList = <String>[];

      hiveFavList.addAll(
        hiveFavorites.map((dynamic id) => id.toString()),
      );

      store.dispatch(
        UpdateStateAction(
          store.state.apiModel.copyWith(favorite: hiveFavList),
        ),
      );
    } catch (e) {}
  }

  Future<void> removeFavorite(String bookId) async {
    try {
      await _collectionService.removeFromCollection(collectionKey, bookId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeFavoriteFromHive(String bookId) async {
    try {
      final box = await Hive.openBox<dynamic>("favoritesBooks");

      var currentFavorites = box.get("favoriteBooks");

      if (currentFavorites == null) {
        return false;
      }

      List<dynamic> favoritesList;
      if (currentFavorites is List) {
        favoritesList = List.from(currentFavorites);
      } else {
        favoritesList = [currentFavorites];
      }

      favoritesList.removeWhere((item) => item.toString() == bookId);

      await box.put("favoriteBooks", favoritesList);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getFavorites() async {
    try {
      final favorites = await _collectionService.getCollection(collectionKey);
      return favorites.map((id) => id.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isFavorite(String bookId) async {
    try {
      final favorites = await getFavorites();
      return favorites.contains(bookId);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _collectionService.clearCollection(collectionKey);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getFavoriteCount() async {
    try {
      final favorites = await getFavorites();
      return favorites.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> addFavorites(List<String> bookIds) async {
    try {
      for (final bookId in bookIds) {
        await addFavorite(bookId);
      }
    } catch (e) {
      rethrow;
    }
  }
}
