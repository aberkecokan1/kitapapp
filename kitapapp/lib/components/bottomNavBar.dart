import 'package:flutter/material.dart';
import 'package:kitapapp/main.dart';
import 'package:kitapapp/screens/book_list.dart';
import 'package:kitapapp/screens/favorites.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class PersistentBottomNavBarWidget extends StatefulWidget {
  const PersistentBottomNavBarWidget({super.key});

  @override
  _PersistentBottomNavBarWidgetState createState() => _PersistentBottomNavBarWidgetState();
}

class _PersistentBottomNavBarWidgetState extends State<PersistentBottomNavBarWidget> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      BookList(),
      FavoritesScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarItems(),
      backgroundColor: store.state.apiModel.theme! ? Colors.black : Colors.white,
      navBarStyle: NavBarStyle.style6,
    );
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.star),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}
