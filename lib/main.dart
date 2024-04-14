import 'package:flutter/material.dart';
import 'package:prototype_ss/page_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 251, 80, 18),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 216, 219, 226),
        ),
        useMaterial3: true,
      ),

      home: const PageSwitcher(),

    );
  }
}