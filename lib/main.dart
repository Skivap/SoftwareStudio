import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prototype_ss/firebase_options.dart';
import 'package:prototype_ss/page_controller.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/provider/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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