abstract class IBookRepository {
  Future<List<dynamic>>   getBooks();
  Future<List<String>> getFavoriteBooks();
  Future<List<dynamic>> fetchBooksFromApi();
  Future<void> addToFavorites(String bookId);
  Future<void> removeFromFavorites(String bookId);
  Future<void> clearAllFavorites();
  Future<List<Map<String, dynamic>>> fetchVillainDetails(List<dynamic> villains);
  Future<List<dynamic>> searchBooks(String query);
}
