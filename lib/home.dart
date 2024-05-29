import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:prototype_ss/views/main_page.dart';
import 'package:prototype_ss/views/search_page.dart';
import 'package:prototype_ss/views/chat.dart';
import 'package:prototype_ss/views/shopping_cart.dart';
class HomePage extends StatefulWidget {
  
  final void Function(String) changePage;
  
  const HomePage({super.key, required this.changePage});

  @override
  State<HomePage> createState() => _HomePage();

}

class _HomePage extends State<HomePage> with TickerProviderStateMixin {

  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context){
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            controller: _pageViewController,
            onPageChanged: _handlePageViewChanged,
            children: <Widget>[
              Center(
                child: MainPage(),
              ),
              Center(
                child: search_page(context),
              ),
              Center(
                child: ShoppingCart(),
              ),
              const Center(
                child: ChatPage(),
              ),
              Center(
                child: Text('Sign up first to reveal this page', style: textTheme.titleLarge),
              ),
            ],
          ),
          PageIndicator(
            tabController: _tabController,
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
        ],
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
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

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final icons = [
      Icons.home,
      Icons.search,
      Icons.shopping_cart,
      Icons.chat,
      Icons.person
    ];

    return Container( 
      padding: const EdgeInsets.all(8.0),

      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        
        children: icons.asMap().entries.map((entry) {
          final index = entry.key;
          final icon = entry.value;
          return GestureDetector(
            onTap: () => onUpdateCurrentPageIndex(index),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                size: 35,
                color: index == currentPageIndex ? Colors.pink[600] : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}