import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/views/main_page.dart';
import 'package:prototype_ss/views/shopping_cart.dart';
import 'package:prototype_ss/views/user_settings.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/widgets/search_grid.dart';

class HomePage extends StatefulWidget {
  
  final void Function(String) changePage;
  
  const HomePage({super.key, required this.changePage});

  @override
  State<HomePage> createState() => _HomePage();

}

class _HomePage extends State<HomePage> with TickerProviderStateMixin {

  int _currentPageIndex = 0;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  final icons = [
    Icons.home,
    Icons.search,
    Icons.shopping_cart,
    // Icons.chat,
    Icons.person
  ];


    String _searchQuery = '';

    Widget searchPage(BuildContext context) {
      final theme = Provider.of<ThemeProvider>(context).theme;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.secondary,
          title: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Abhaya Libre SemiBold', 
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              padding: const EdgeInsets.only(
                top: 20,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: buildSearchBar(context, setState),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: SearchGrid(
                      searchQuery: _searchQuery,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        )
      );
    }

    Widget buildSearchBar(BuildContext context, StateSetter setState) {
      final theme = Provider.of<ThemeProvider>(context).theme;
      return TextField(
        style: TextStyle(color: theme.colorScheme.onPrimary),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search products...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onPrimary
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      );
    }


  @override
  Widget build(BuildContext context){
    final theme = Provider.of<ThemeProvider>(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
              color: theme.colorScheme.onPrimary
            )
          )
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            if(_isMounted){
              setState(() {
                _currentPageIndex = index;
              });
            }
          },
          indicatorColor: theme.colorScheme.tertiary,
          backgroundColor: theme.colorScheme.secondary,
          selectedIndex: _currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.checkroom_rounded),
              label: 'Wardrobe',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ]
        )
      ),
      body: <Widget>[
        const MainPage(),
        searchPage(context),
        const ShoppingCart(),
        // const ChatPage(),
        UserSettings(changePage: widget.changePage)
      ][_currentPageIndex]
    );
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}