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
  Widget build(BuildContext context){
    Widget page = LoginPage(changePage: changePage);

    if(currentPage == "Login"){
      page = LoginPage(changePage: changePage);
    }
    else if (currentPage == "SignUp"){
      page = SignUpPage(changePage: changePage);
    }
    else if(currentPage == "Home"){
      page = HomePage(changePage: changePage);
    }
    
    return page;
  }
}