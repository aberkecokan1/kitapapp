import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kitapapp/db/favori_books.dart';
import 'package:kitapapp/db/storage.dart';
import 'package:kitapapp/db/store_factory.dart';
import 'package:kitapapp/exception/api_error.dart';
import 'package:kitapapp/services/repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([http.Client, IStorageService, FavoriteBooksService, StorageServiceFactory])
import 'book_repository_test.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late MockIStorageService mockStorageService;
  late MockFavoriteBooksService mockFavoritesService;
  late MockStorageServiceFactory mockStorageFactory;
  late TestableBookRepository repository;

  setUp(() {
    mockHttpClient = MockClient();
    mockStorageService = MockIStorageService();
    mockFavoritesService = MockFavoriteBooksService();
    mockStorageFactory = MockStorageServiceFactory();

    when(mockStorageFactory.getBoxService('booksBox')).thenReturn(mockStorageService);
    when(mockStorageFactory.getFavoriteBooksService('favoritesBooks'))
        .thenReturn(mockFavoritesService);

    repository = TestableBookRepository(
      mockHttpClient,
      mockStorageService,
      mockFavoritesService,
    );
  });

  group('getBooks', () {
    test('önbellek verileri varsa, önbellekten kitapları almalı', () async {
      final mockBooks = [
        {'id': '1', 'Title': 'The Shining'},
        {'id': '2', 'Title': 'It'}
      ];
      when(mockStorageService.get('books', defaultValue: anyNamed('defaultValue')))
          .thenAnswer((_) async => mockBooks);

      final result = await repository.getBooks();

      expect(result, equals(mockBooks));
      verify(mockStorageService.get('books', defaultValue: anyNamed('defaultValue'))).called(1);
    });

    test('önbellek boşsa boş liste döndürmeli', () async {
      when(mockStorageService.get('books', defaultValue: anyNamed('defaultValue')))
          .thenAnswer((_) async => null);

      final result = await repository.getBooks();

      expect(result, equals([]));
      verify(mockStorageService.get('books', defaultValue: anyNamed('defaultValue'))).called(1);
    });
  });

  group('fetchBooksFromApi', () {
    test('başarılı API yanıtını işlemeli ve verileri kaydetmeli', () async {
      final mockApiResponse = {
        'data': [
          {'id': '1', 'Title': 'The Shining'},
          {'id': '2', 'Title': 'It'}
        ]
      };

      when(mockHttpClient.get(Uri.parse('https://stephen-king-api.onrender.com/api/books')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockApiResponse), 200));

      final result = await repository.fetchBooksFromApi();

      expect(result.length, equals(2));
      expect(result[0]['Title'], equals('The Shining'));
      expect(result[1]['Title'], equals('It'));

      verify(mockStorageService.save('books', any)).called(1);
    });

    test('API hatasında uygun istisna atmalı', () async {
      when(mockHttpClient.get(Uri.parse('https://stephen-king-api.onrender.com/api/books')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      expect(() => repository.fetchBooksFromApi(), throwsA(isA<ApiServerException>()));
    });

    test('geçersiz JSON formatında uygun istisna atmalı', () async {
      when(mockHttpClient.get(Uri.parse('https://stephen-king-api.onrender.com/api/books')))
          .thenAnswer((_) async => http.Response('Not a valid JSON', 200));

      expect(() => repository.fetchBooksFromApi(), throwsA(isA<ApiDataException>()));
    });

    test('"data" alanı olmayan API yanıtında uygun istisna atmalı', () async {
      when(mockHttpClient.get(Uri.parse('https://stephen-king-api.onrender.com/api/books')))
          .thenAnswer((_) async => http.Response('{"result": []}', 200));

      expect(() => repository.fetchBooksFromApi(), throwsA(isA<ApiDataException>()));
    });
  });

  group('searchBooks', () {
    test('kitapları başlığa göre filtrelemeli', () async {
      final mockBooks = [
        {'id': '1', 'Title': 'The Shining'},
        {'id': '2', 'Title': 'It'},
        {'id': '3', 'Title': 'The Green Mile'}
      ];

      when(mockStorageService.get('books', defaultValue: anyNamed('defaultValue')))
          .thenAnswer((_) async => mockBooks);

      final result = await repository.searchBooks('the');

      expect(result.length, equals(2));
      expect(result[0]['Title'], equals('The Shining'));
      expect(result[1]['Title'], equals('The Green Mile'));
    });

    test('boş sorgu tüm kitapları döndürmeli', () async {
      final mockBooks = [
        {'id': '1', 'Title': 'The Shining'},
        {'id': '2', 'Title': 'It'}
      ];

      when(mockStorageService.get('books', defaultValue: anyNamed('defaultValue')))
          .thenAnswer((_) async => mockBooks);

      final result = await repository.searchBooks('');

      expect(result, equals(mockBooks));
    });
  });

  group('favorites', () {
    test('addToFavorites favoriler listesine eklenmeli', () async {
      const bookId = '1';

      await repository.addToFavorites(bookId);

      verify(mockFavoritesService.addFavorite(bookId)).called(1);
    });

    test('removeFromFavorites favoriler listesinden kaldırmalı', () async {
      const bookId = '1';

      await repository.removeFromFavorites(bookId);

      verify(mockFavoritesService.removeFavorite(bookId)).called(1);
    });

    test('isBookFavorite bir kitabın favori olup olmadığını kontrol etmeli', () async {
      const bookId = '1';
      when(mockFavoritesService.isFavorite(bookId)).thenAnswer((_) async => true);

      final result = await repository.isBookFavorite(bookId);

      expect(result, isTrue);
      verify(mockFavoritesService.isFavorite(bookId)).called(1);
    });

    test('getFavoriteBooksDetails favori kitapların detaylarını getirmeli', () async {
      final mockBooks = [
        {'id': '1', 'Title': 'The Shining'},
        {'id': '2', 'Title': 'It'},
        {'id': '3', 'Title': 'The Green Mile'}
      ];

      final mockFavorites = ['1', '3'];

      when(mockStorageService.get('books', defaultValue: anyNamed('defaultValue')))
          .thenAnswer((_) async => mockBooks);
      when(mockFavoritesService.getFavorites()).thenAnswer((_) async => mockFavorites);

      final result = await repository.getFavoriteBooksDetails();

      expect(result.length, equals(2));
      expect(result[0]['id'], equals('1'));
      expect(result[1]['id'], equals('3'));
    });
  });
}

class TestableBookRepository implements IBookRepository {
  final http.Client client;
  final IStorageService storageService;
  final FavoriteBooksService favoritesService;
  final String apiUrl = "https://stephen-king-api.onrender.com/api/books";

  TestableBookRepository(
    this.client,
    this.storageService,
    this.favoritesService,
  );

  @override
  Future<List<dynamic>> getBooks() async {
    final result = await storageService.get('books', defaultValue: <dynamic>[]);

    if (result is List) {
      return result;
    }

    return <dynamic>[];
  }

  @override
  Future<List<String>> getFavoriteBooks() async {
    return await favoritesService.getFavorites();
  }

  Future<List<dynamic>> fetchBooksFromApi() async {
    try {
      final response = await client.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15));

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
          await storageService.save('books', bookList);
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
    } on ApiDataException {
      rethrow;
    } on ApiServerException {
      rethrow;
    } on ApiAuthException {
      rethrow;
    } on ApiTimeoutException {
      rethrow;
    } on ApiConnectionException {
      rethrow;
    } catch (e) {
      throw ApiException('Beklenmeyen hata: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchVillainDetails(List<dynamic> villains) async {
    if (villains.isEmpty) return [];

    List<Map<String, dynamic>> villainDetails = [];

    try {
      for (var villain in villains) {
        if (villain['url'] == null) continue;
        if (villain['url'] is! String) continue;

        final response = await client.get(Uri.parse(villain['url'].toString()));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (jsonResponse.containsKey('data')) {
            final Map<String, dynamic> data = jsonResponse['data'] as Map<String, dynamic>;
            villainDetails.add(data);
          }
        }
      }
    } catch (e) {
      print("Catch $e");
    }

    return villainDetails;
  }

  @override
  Future<void> addToFavorites(String bookId) async {
    await favoritesService.addFavorite(bookId);
  }

  @override
  Future<void> removeFromFavorites(String bookId) async {
    await favoritesService.removeFavorite(bookId);
  }

  @override
  Future<void> clearAllFavorites() async {
    await favoritesService.clearAllFavorites();
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
    return await favoritesService.isFavorite(bookId);
  }

  Future<List<dynamic>> getFavoriteBooksDetails() async {
    final books = await getBooks();
    final favorites = await getFavoriteBooks();

    return books.where((book) => favorites.contains(book['id'].toString())).toList();
  }
}
