import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:hive/hive.dart';
import 'package:kitapapp/components/dialog.dart';
import 'package:kitapapp/db/favori_books.dart';
import 'package:kitapapp/main.dart';
import 'package:kitapapp/models/actions.dart';
import 'package:kitapapp/models/api_model.dart';
import 'package:kitapapp/models/redux_model.dart';
import 'package:kitapapp/screens/book_detail.dart';
import 'package:kitapapp/services/notifications.dart';
import 'package:kitapapp/services/repository.dart';
import 'package:kitapapp/services/services_imp/repo_services_impl.dart';
import 'package:kitapapp/components/dialog.dart' as app_dialog;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookList extends StatefulWidget {
  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  final IBookRepository _bookRepository = BookRepository();
  FavoriteBooksService favoriteBooksService = FavoriteBooksService.instance();
  final INotificationService _notificationService = NotificationService();

  List<dynamic> books = [];
  List<String> fav = [];
  List<dynamic> filteredBooks = [];

  TextEditingController searchController = TextEditingController();

  void filterBooks(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredBooks = books;
      });
      return;
    }

    final filtered = books.where((book) {
      final title = book['Title'].toLowerCase();
      final searchTerm = query.toLowerCase();
      return title.contains(searchTerm) as bool;
    }).toList();

    setState(() {
      filteredBooks = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    books = store.state.apiModel.books ?? [];

    fav = store.state.apiModel.favorite!.map((id) => id.toString()).toList();

    filteredBooks = books;
  }

  int? savedHour;
  int? savedMinute;

  void _saveTime(int hour, int minute) {
    setState(() {
      savedHour = hour;
      savedMinute = minute;
    });
    _notificationService.scheduleDailyNotification(savedHour!, savedMinute!);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(store.state.apiModel.language!),
      supportedLocales: [
        Locale('en'),
        Locale('tr'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.black54,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black87,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardTheme(
          color: Colors.grey.shade800,
          shadowColor: Colors.black54,
        ),
        iconTheme: IconThemeData(
          color: Colors.white70,
        ),
      ),
      themeMode: store.state.apiModel.theme! ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                store.dispatch(UpdateStateAction(
                  store.state.apiModel.copyWith(theme: !store.state.apiModel.theme!),
                ));
                setState(() {});
              },
              icon: Icon(Icons.dark_mode),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return app_dialog.TimePickerDialog(
                      onSave: _saveTime,
                    );
                  },
                );
              },
              icon: Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () {
                store.dispatch(UpdateStateAction(
                  store.state.apiModel
                      .copyWith(language: store.state.apiModel.language == "en" ? "tr" : "en"),
                ));
              },
              icon: Icon(Icons.language),
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: StoreProvider<ReduxModel>(
            store: store,
            child: StoreConnector<ReduxModel, ReduxModel>(
              onWillChange: (previousViewModel, newViewModel) {
                setState(() {
                  fav = newViewModel.apiModel.favorite!.map((id) => id.toString()).toList();
                });
              },
              builder: (context, state) {
                bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: searchController,
                            onChanged: (query) {
                              filterBooks(query);
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.ara,
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.01,
                          ),
                          shrinkWrap: false,
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];

                            String bookId = book['id'].toString();

                            bool isFavorite = fav.contains(bookId);

                            return GestureDetector(
                              onDoubleTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (context) => BookDetailScreen(),
                                  ),
                                );
                                store.dispatch(UpdateStateAction(
                                  store.state.apiModel.copyWith(index: index),
                                ));
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isFavorite ? Colors.amber.shade300 : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.blue.shade800
                                                  : Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#${book['id']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.blue.shade800,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              book['Year'].toString(),
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        book['Title'].toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${book['Pages']} ${AppLocalizations.of(context)?.sayfa}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDarkMode
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isFavorite ? Icons.star : Icons.star_border,
                                              color: isFavorite ? Colors.amber : Colors.grey,
                                              size: 28,
                                            ),
                                            onPressed: () async {
                                              if (isFavorite) {
                                                List<String> updatedFav = List<String>.from(fav);
                                                updatedFav.removeWhere((id) => id == bookId);

                                                setState(() {
                                                  fav = updatedFav;
                                                });

                                                store.dispatch(UpdateStateAction(
                                                  store.state.apiModel.copyWith(
                                                    favorite: updatedFav,
                                                  ),
                                                ));
                                                favoriteBooksService.removeFavorite(bookId);
                                              } else {
                                                fav.add(bookId);
                                                store.dispatch(UpdateStateAction(
                                                  store.state.apiModel.copyWith(
                                                    favorite: fav,
                                                  ),
                                                ));

                                                _bookRepository.addToFavorites(bookId);
                                              }

                                              setState(() {});
                                            },
                                            splashRadius: 24,
                                            tooltip: isFavorite
                                                ? 'Favorilerden Çıkar'
                                                : 'Favorilere Ekle',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                );
              },
              converter: (store) => store.state,
            ),
          ),
        ),
      ),
    );
  }
}
