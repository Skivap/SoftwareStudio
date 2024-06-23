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


  io.File? _pickedImage;
  String? _imageUrl;
   Future<void> pickImage(StateSetter setModalState) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (universal_io.Platform.isAndroid || universal_io.Platform.isIOS) {
        setModalState(() {
          _pickedImage = io.File(pickedImage.path);
          
        });
      } else {
        String? uploadedImageUrl = await uploadImageWeb(pickedImage);
        setModalState(() {
          _imageUrl = uploadedImageUrl;
        });
      }
      
      
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<String?> uploadImage(io.File image) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$filename');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<String?> uploadImageWeb(XFile image) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$filename');
      UploadTask uploadTask = storageRef.putData(await image.readAsBytes());
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

void addProduct() async {
    String productName = _productNameController.text.trim();
    String productPrice = _productPriceController.text.trim();
    String productDescription = _productDescriptionController.text.trim();
    String productLink = _productLinkUrlController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid ?? '';

    if (productName.isNotEmpty &&
        productPrice.isNotEmpty &&
        productDescription.isNotEmpty &&
        (_pickedImage != null || _imageUrl != null) &&
        productLink.isNotEmpty) {
      try {
        String? imageUrl;
        if (_pickedImage != null) {
          imageUrl = await uploadImage(_pickedImage!);
        } else {
          imageUrl = _imageUrl;
        }

        if (imageUrl != null) {
         await _firestore.collection('products').add({
            'sellerId': userId,
            'name': productName,
            'price': double.parse(productPrice),
            'description': productDescription,
            'imageUrl': imageUrl,
            'link': productLink,
            'likedby': [],
            'likes':0,
            'comment_count': 0,
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product Added Successfully')),
          );
          Navigator.pop(context);

          _productNameController.clear();
          _productPriceController.clear();
          _productDescriptionController.clear();
          _productLinkUrlController.clear();
          if(_isMounted){
            setState(() {
              _pickedImage = null;
              _imageUrl = null;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload Image')),
          );
        }
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
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
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_pickedImage == null && _imageUrl == null)
                    GestureDetector(
                      onTap: () => pickImage(setModalState),
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
                  else if (_pickedImage != null)
                    GestureDetector(
                      onTap: () => pickImage(setModalState),
                      child: Image.file(
                        _pickedImage!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (_imageUrl != null)
                    GestureDetector(
                      onTap: () => pickImage(setModalState),
                      child: Image.network(
                        _imageUrl!,
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
                  TextField(
                    controller: _productLinkUrlController,
                    decoration: const InputDecoration(labelText: 'Product Link'),
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
    },
  );
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
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              color: theme.colorScheme.onPrimary,
              onPressed: () {showProductForm(context);},
            ),
          ],
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
