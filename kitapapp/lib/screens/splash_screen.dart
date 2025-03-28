import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kitapapp/components/bottomNavBar.dart';
import 'package:kitapapp/main.dart';
import 'package:kitapapp/models/actions.dart';
import 'package:kitapapp/models/api_model.dart';
import 'package:kitapapp/models/redux_model.dart';

import 'package:kitapapp/services/notifications.dart';
import 'package:kitapapp/services/permission.dart';
import 'package:kitapapp/services/repository.dart';
import 'package:kitapapp/services/services_imp/permission_services_impl.dart';
import 'package:kitapapp/services/services_imp/repo_services_impl.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  const SplashScreen({super.key, required this.isDarkMode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final IBookRepository _bookRepository = BookRepository();
  final INotificationService _notificationService = NotificationService();
  final IPermissionService _permissionService = PermissionService();

  @override
  void initState() {
    _initializeData();

    super.initState();
  }

  Future<void> _initializeData() async {
    try {
      await _loadBooks();

      await _notificationService.initialize();

      await _permissionService.requestNotificationPermission();

      final favoriteBooks = await _bookRepository.getFavoriteBooks();

      if (mounted) {
        StoreProvider.of<ReduxModel>(context).dispatch(
          UpdateStateAction(store.state.apiModel.copyWith(
            favorite: favoriteBooks,
          )),
        );
      }
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookRepository.fetchBooksFromApi();
      if (mounted) {
        StoreProvider.of<ReduxModel>(context).dispatch(
          UpdateStateAction(store.state.apiModel.copyWith(
            books: books,
          )),
        );
      }
      print(books);
    } catch (e) {
      print('API error, loading from local storage: $e');

      final books = await _bookRepository.getBooks();

      if (mounted) {
        StoreProvider.of<ReduxModel>(context).dispatch(
          UpdateStateAction(store.state.apiModel.copyWith(
            books: books,
          )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasySplashScreen(
        loaderColor: widget.isDarkMode ? Colors.white : Colors.blue,
        logo: Image.asset(
          "assets/images/stephen.png",
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
        logoWidth: 150,
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        durationInSeconds: 6,
        showLoader: true,
        navigator: PersistentBottomNavBarWidget(),
      ),
    );
  }
}
