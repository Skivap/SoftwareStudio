import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_ss/widgets/product_page.dart';

var headerStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 30,
);

List<String> banners = ['banner1', 'banner2', 'banner3'];

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
  final TextEditingController _productImageUrlController = TextEditingController();
  late PageController _bannerPageController;
  late Timer _bannerTimer;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(initialPage: 0);
    _bannerTimer = Timer.periodic(const Duration(seconds: 7), (Timer timer) {
      if (_currentBannerPage < banners.length - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }

      _bannerPageController.animateToPage(
        _currentBannerPage,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerTimer.cancel();
    _bannerPageController.dispose();
  }

  void showProductForm(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _productPriceController,
                  decoration: InputDecoration(labelText: 'Product Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _productDescriptionController,
                  decoration: InputDecoration(labelText: 'Product Description'),
                ),
                TextField(
                  controller: _productImageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: addProduct,
                  child: Text('Add Product'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void addProduct() async {
    String productName = _productNameController.text.trim();
    String productPrice = _productPriceController.text.trim();
    String productDescription = _productDescriptionController.text.trim();
    String productImageUrl = _productImageUrlController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid ?? '';

    if (productName.isNotEmpty &&
        productPrice.isNotEmpty &&
        productDescription.isNotEmpty &&
        productImageUrl.isNotEmpty) {
      try {
        await _firestore.collection('products').add({
          'sellerId': userId,
          'name': productName,
          'price': double.parse(productPrice),
          'description': productDescription,
          'imageUrl': productImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product Added Successfully')),
        );
        Navigator.pop(context); // Close the bottom sheet

        // Clear the input fields after adding the product
        _productNameController.clear();
        _productPriceController.clear();
        _productDescriptionController.clear();
        _productImageUrlController.clear();
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double myWidth = MediaQuery.of(context).size.width;
    double myHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: myWidth,
              height: myHeight * 0.15,
              child: PageView.builder(
                controller: _bannerPageController,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    'assets/images/banners/${banners[index]}.jpg',
                    fit: BoxFit.fill,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Recommended For You ',
                style: headerStyle,
              ),
            ),
            SizedBox(
              height: myHeight * 0.3,
              child: ProductPage(scrollDirection: Axis.horizontal),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Trending Styles',
                style: headerStyle,
              ),
            ),
            SizedBox(
              height: myHeight * 0.3,
              child: ProductPage(scrollDirection: Axis.horizontal),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    showProductForm(context);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.blue,
                )
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
