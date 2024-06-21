import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prototype_ss/widgets/product_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  File? _pickedImage;

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

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null){
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> uploadImage(File image) async {
     try {
       String filename = DateTime.now().millisecondsSinceEpoch.toString();
       Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$filename');
       UploadTask uploadTask = storageRef.putFile(image);
       await uploadTask.whenComplete(() {});
       return await storageRef.getDownloadURL();
    } catch(e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void addProduct() async {
    String productName = _productNameController.text.trim();
    String productPrice = _productPriceController.text.trim();
    String productDescription = _productDescriptionController.text.trim();
    //String productImageUrl = _productImageUrlController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid ?? '';

    if (productName.isNotEmpty &&
        productPrice.isNotEmpty &&
        productDescription.isNotEmpty && 
        _pickedImage != null){
        //productImageUrl.isNotEmpty) {
      try {
        String? imageUrl = await uploadImage(_pickedImage!);
        if (imageUrl != null) {
          await _firestore.collection('products').add({
            'sellerId': userId,
            'name': productName,
            'price': double.parse(productPrice),
            'description': productDescription,
            'imageUrl': imageUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product Added Successfully')),
          );
          Navigator.pop(context);

          _productNameController.clear();
          _productPriceController.clear();
          _productDescriptionController.clear();
          _productImageUrlController.clear();
          setState(() {
            _pickedImage = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload Image'))
          );
        }
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _pickedImage == null
                      ? GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 200,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: pickImage,
                          child: Image.file(
                            _pickedImage!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _productPriceController,
                  decoration: const InputDecoration(labelText: 'Product Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _productDescriptionController,
                  decoration: const InputDecoration(labelText: 'Product Description'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: addProduct,
                  child: const Text('Add Product'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double myWidth = MediaQuery.of(context).size.width;
    double myHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
          child:
            Column(
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
                  child: const ProductPage(scrollDirection: Axis.horizontal),
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
                  child: const ProductPage(scrollDirection: Axis.horizontal),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child:FloatingActionButton(
              onPressed: () {
                showProductForm(context);
              },
              backgroundColor: const Color.fromRGBO(244, 40, 53, 32),
              child: const Icon(Icons.add),
            )
          )
        ]
      ),
    );
  }
}
