import 'package:flutter/material.dart';
import 'package:prototype_ss/home.dart';
import 'package:prototype_ss/views/login.dart';
import 'package:prototype_ss/views/signup.dart';

class PageSwitcher extends StatefulWidget {
  
  const PageSwitcher({super.key});

  @override
  State<PageSwitcher> createState() => _PageSwitcher();
}

class _PageSwitcher extends State<PageSwitcher> {

  String currentPage = "Login";

  void changePage(String text){
    setState(() {
      currentPage = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (currentPage) {
      case "Login":
        page = LoginPage(changePage: changePage);
        break;
      case "SignUp":
        page = SignUpPage(changePage: changePage);
        break;
      case "Home":
        page = HomePage(changePage: changePage);
        break;
      default:
        page = LoginPage(changePage: changePage);
        break;
    }

    return MaterialApp(
      home: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: page,
        ),
      ),
    );
  }
}