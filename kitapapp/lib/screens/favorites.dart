import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kitapapp/main.dart';
import 'package:kitapapp/models/actions.dart';
import 'package:kitapapp/models/api_model.dart';
import 'package:kitapapp/models/redux_model.dart';
import 'package:kitapapp/screens/book_detail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> fav = [];
  List<dynamic> favList = [];

  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavoriteBooks();
  }

  void loadFavoriteBooks() {
    setState(() {
      isLoading = true;
    });

    books = store.state.apiModel.books!;

    fav = store.state.apiModel.favorite!.map((id) => id.toString()).toList();

    favList.clear();

    for (var book in books) {
      String bookId = book['id'].toString();
      if (fav.contains(bookId)) {
        favList.add(book);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ReduxModel, ReduxModel>(
      converter: (store) => store.state,
      builder: (context, state) {
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
          home: FavoriteBooksPage(
            favList: favList,
            fav: fav,
            isLoading: isLoading,
            loadFavoriteBooks: loadFavoriteBooks,
          ),
        );
      },
    );
  }
}

class FavoriteBooksPage extends StatefulWidget {
  final List<dynamic> favList;
  final List<String> fav;
  final bool isLoading;
  final Function loadFavoriteBooks;

  const FavoriteBooksPage({
    required this.favList,
    required this.fav,
    required this.isLoading,
    required this.loadFavoriteBooks,
    Key? key,
  }) : super(key: key);

  @override
  _FavoriteBooksPageState createState() => _FavoriteBooksPageState();
}

class _FavoriteBooksPageState extends State<FavoriteBooksPage> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: isDarkMode ? 'Açık Tema' : 'Koyu Tema',
            onPressed: () {
              store.dispatch(UpdateStateAction(
                store.state.apiModel.copyWith(
                  theme: !store.state.apiModel.theme!,
                ),
              ));
            },
          ),
        ],
      ),
      body: StoreConnector<ReduxModel, ReduxModel>(
        onWillChange: (previousViewModel, newViewModel) {
          if (previousViewModel?.apiModel.favorite != newViewModel.apiModel.favorite) {
            widget.loadFavoriteBooks();
          }
        },
        converter: (store) => store.state,
        builder: (context, state) {
          if (widget.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (widget.favList.isEmpty) {
            return buildEmptyState(context, isDarkMode);
          }

          return buildFavoritesList(context, isDarkMode);
        },
      ),
    );
  }

  Widget buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_border,
              size: 80,
              color: Colors.amber,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "${AppLocalizations.of(context)?.favoriyer}",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade800),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "${AppLocalizations.of(context)?.favoriki}",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget buildFavoritesList(BuildContext context, bool isDarkMode) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.01,
        ),
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        itemCount: widget.favList.length,
        itemBuilder: (context, index) {
          if (index >= widget.favList.length) {
            return SizedBox();
          }

          final book = widget.favList[index];
          String bookId = book['id'].toString();

          return GestureDetector(
            onTap: () {
              int originalIndex = 0;
              for (int i = 0; i < store.state.apiModel.books!.length; i++) {
                var originalBook = store.state.apiModel.books![i];
                if (originalBook['id'].toString() == bookId) {
                  originalIndex = i;
                  break;
                }
              }

              store.dispatch(UpdateStateAction(
                store.state.apiModel.copyWith(index: originalIndex),
              ));
              Navigator.push(
                context,
                MaterialPageRoute<dynamic>(builder: (context) => BookDetailScreen()),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.amber.shade300,
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
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${book['id']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.blue.shade800,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            book['Year'].toString(),
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
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
                          '${book['Pages']} ${"${AppLocalizations.of(context)?.sayfa}"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
