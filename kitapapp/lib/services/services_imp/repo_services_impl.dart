// Repository uygulaması
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kitapapp/db/favori_books.dart';
import 'package:kitapapp/db/storage.dart';
import 'package:kitapapp/db/store_factory.dart';
import 'package:kitapapp/exception/api_error.dart';
import 'package:kitapapp/services/repository.dart';
import 'package:http/http.dart' as http;

class BookRepository implements IBookRepository {
  final String _apiUrl = "https://stephen-king-api.onrender.com/api/books";
  final IStorageService _storageService;
  final FavoriteBooksService _favoritesService;

  static final BookRepository _instance = BookRepository._internal();

  factory BookRepository() {
    return _instance;
  }

  BookRepository._internal()
      : _storageService = StorageServiceFactory().getBoxService('booksBox'),
        _favoritesService = StorageServiceFactory().getFavoriteBooksService('favoritesBooks');

  @override
  Future<List<dynamic>> getBooks() async {
    final result = await _storageService.get('books', defaultValue: <dynamic>[]);

    if (result is List) {
      return result;
    }

    return <dynamic>[];
  }

  @override
  Future<List<String>> getFavoriteBooks() async {
    return await _favoritesService.getFavorites();
  }

  Future<http.Response> getHttp(Uri url) {
    return http.get(url);
  }

  Future<List<dynamic>> fetchBooksFromApi() async {
    try {
      final response = await getHttp(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final Map<String, dynamic> jsonResponse =
              jsonDecode(response.body) as Map<String, dynamic>;

          if (!jsonResponse.containsKey('data')) {
            throw ApiDataException('API yanıtında "data" alanı bulunamadı');
          }

          final dynamic dataField = jsonResponse['data'];
          if (dataField is! List) {
            throw ApiDataException(
                'API yanıtında "data" alanı bir liste değil: ${dataField.runtimeType}');
          }

          final List<dynamic> bookList = dataField;

          // Verileri kaydet
          await _storageService.save('books', bookList);

          return bookList;
        } on FormatException catch (e) {
          throw ApiDataException('Geçersiz JSON formatı: ${e.message}');
        }
      } else if (response.statusCode == 401) {
        throw ApiAuthException('Kimlik doğrulama hatası: ${response.statusCode}');
      } else if (response.statusCode >= 500) {
        throw ApiServerException('Sunucu hatası: ${response.statusCode}');
      } else {
        throw ApiException('API isteği başarısız: ${response.statusCode}');
      }
    } on TimeoutException {
      throw ApiTimeoutException('API isteği zaman aşımına uğradı');
    } on SocketException catch (e) {
      throw ApiConnectionException('Ağ bağlantı hatası: ${e.message}');
    } catch (e) {
      throw ApiException('Beklenmeyen hata: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVillainDetails(List<dynamic> villains) async {
    if (villains.isEmpty) return [];

    List<Map<String, dynamic>> villainDetails = [];

    try {
      for (var villain in villains) {
        print(villain['url']);
        final url = villain['url'];
        print(url);

        if (url == null) continue;

        if (url is! String) continue;

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (jsonResponse.containsKey('data')) {
            final Map<String, dynamic> data = jsonResponse['data'] as Map<String, dynamic>;

            villainDetails.add(data);
            print(villainDetails);
          }
        } else {}
      }
    } catch (e) {
      print("Catch $e");
    }

    return villainDetails;
  }

  @override
  Future<void> addToFavorites(String bookId) async {
    await _favoritesService.addFavorite(bookId);
  }

  @override
  Future<void> removeFromFavorites(String bookId) async {
    await _favoritesService.removeFavorite(bookId);
  }

  @override
  Future<void> clearAllFavorites() async {
    await _favoritesService.clearAllFavorites();
  }

  @override
  Future<List<dynamic>> searchBooks(String query) async {
    final books = await getBooks();

    if (query.isEmpty) {
      return books;
    }

    return books.where((book) {
      final title = book['Title'].toString().toLowerCase();
      final searchTerm = query.toLowerCase();
      return title.contains(searchTerm);
    }).toList();
  }

  Future<bool> isBookFavorite(String bookId) async {
    return await _favoritesService.isFavorite(bookId);
  }

  Future<List<dynamic>> getFavoriteBooksDetails() async {
    final books = await getBooks();
    final favorites = await getFavoriteBooks();

    return books.where((book) => favorites.contains(book['id'].toString())).toList();
  }
}
