import 'dart:io' as io;
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart' as universal_io;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/widgets/product_page.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productLinkUrlController = TextEditingController();
  // ignore: unused_field
  late PageController _bannerPageController;

  io.File? _pickedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    final theme = Provider.of<ThemeProvider>(context).theme;

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.secondary,
          leading: const Padding(
            padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 5.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'), // Your profile image asset
            ),
          ),
          title:  Padding(
            padding: const EdgeInsets.only(top:8.0, bottom: 8.0, left: 5.0),
            child: Text(
              'Trendify',
              style: TextStyle(
                fontFamily: 'Billabong', // Use the Instagram font
                fontSize: 32,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          
        ),
        backgroundColor: theme.colorScheme.primary,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: myHeight,
                    child: const ProductPage(),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
