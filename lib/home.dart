import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/views/main_page.dart';
import 'package:prototype_ss/views/search_page.dart';
import 'package:prototype_ss/views/chat.dart';
import 'package:prototype_ss/views/shopping_cart.dart';
import 'package:prototype_ss/views/user_settings.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  
  final void Function(String) changePage;
  
  const HomePage({super.key, required this.changePage});

  @override
  State<HomePage> createState() => _HomePage();

}

class _HomePage extends State<HomePage> with TickerProviderStateMixin {

  int _currentPageIndex = 0;

  final icons = [
    Icons.home,
    Icons.search,
    Icons.shopping_cart,
    Icons.chat,
    Icons.person
  ];

  @override
  Widget build(BuildContext context){
    final theme = Provider.of<ThemeProvider>(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(
              color: theme.colorScheme.onPrimary
            )
          )
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          indicatorColor: theme.colorScheme.tertiary,
          backgroundColor: theme.colorScheme.secondary,
          selectedIndex: _currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              // icon: Badge(child: Icon(Icons.home)),
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              // icon: Badge(child: Icon(Icons.search)),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.checkroom_rounded),
              // icon: Badge(child: Icon(Icons.shopping_cart)),
              label: 'Wardrobe',
            ),
            NavigationDestination(
              icon: Icon(Icons.messenger_sharp),
              // icon: Badge(
              //   label: Text('2'),
              //   child: Icon(Icons.messenger_sharp),
              // ),
              label: 'Message',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              //icon: Badge(child: Icon(Icons.notifications_sharp)),
              label: 'Settings',
            ),
          ]
        )
      ),
      body: <Widget>[
        const MainPage(),
        searchPage(context),
        const ShoppingCart(),
        const ChatPage(),
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