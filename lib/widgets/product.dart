import 'package:flutter/material.dart';
import 'package:prototype_ss/model/product_model.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:universal_io/io.dart' as universal_io;

class ProductContent extends StatefulWidget {
  final Product productData;
  final bool showExitButton;

  const ProductContent({
    super.key,
    required this.productData,
    this.showExitButton = false,
  });

  @override
  State<ProductContent> createState() {
    return _ProductState();
  }
}

class _ProductState extends State<ProductContent> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productLinkUrlController = TextEditingController();
  // ignore: unused_field
  late PageController _bannerPageController;

  io.File? _pickedImage;
  String? _imageUrl;
  String imageLink = '';
  String username = '';
  late int likes;
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    likes = widget.productData.likes;
    isLiked = widget.productData.likedby.contains(FirebaseAuth.instance.currentUser?.uid);
    getUserInfo(widget.productData.sellerID);
  }
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
          setState(() {
            _pickedImage = null;
            _imageUrl = null;
          });
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

  void _toggleLike() async {
    final int previousLikes = likes;
    final bool previousIsLiked = isLiked;

    setState(() {
      isLiked = !isLiked;
      likes += isLiked ? 1 : -1;
    });

    try {
      await _firestoreService.likePost(widget.productData.id, previousIsLiked);
    } catch (e) {
      setState(() {
        isLiked = previousIsLiked;
        likes = previousLikes;
      });
      print("Error liking post: $e");
    }
  }

  void getUserInfo(String userId) async {
    try {
      const Duration timeoutDuration = Duration(seconds: 10);
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .timeout(timeoutDuration);

      if (querySnapshot.exists) {
        if (mounted) {
          setState(() {
            username = querySnapshot.data()?['name'] ?? '';
            imageLink = querySnapshot.data()?['imageLink'] ?? '';
          });
        }
      } else {
        if (mounted) {
          print('Document does not exist');
        }
      }
    } on TimeoutException catch (_) {
      setState(() {
        username = 'Timeout';
      });
      print('Timeout occurred');
    } catch (e) {
      setState(() {
        username = '$e';
      });
      print('Error: $e');
    }
  }

  // void addProduct(String userId) async {
  //   final User? user = FirebaseAuth.instance.currentUser;
  //   if (user == null){
  //     showErrorDialog(context, 'No user is signed in');
  //     return;
  //   }

  //   final String userId = user.uid;
  //   final CollectionReference cartRef = FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(userId)
  //     .collection('cart');

  //   try {
  //     final QuerySnapshot existingProduct = await cartRef
  //       .where('productId', isEqualTo: widget.productData.id)
  //       .limit(1)
  //       .get(); 
      
  //     if (existingProduct.docs.isEmpty){
  //       await cartRef.add({
  //         'productId': widget.productData.id,
  //         'productName': widget.productData.name
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Product added to wardrobe')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Product already in wardrobe')),
  //       );
  //     }
  //   } catch(e){
  //     //print('Error adding product to wardrobe: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to add product to wardrobe: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 50,),
          Row(
            children: [
              if (widget.showExitButton)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              const SizedBox(width: 5),
              CircleAvatar(
                backgroundImage: NetworkImage(imageLink.isNotEmpty ? imageLink : 'https://free-icon-rainbow.com/i/icon_01993/icon_019930_256.jpg'),
              ),
              const SizedBox(width: 8.0),
              Text(
                username,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.secondary),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 400
                ),
                child: Image.network(
                  widget.productData.imageUrl,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                      color: isLiked ? theme.colorScheme.tertiary : theme.colorScheme.onPrimary,
                      onPressed: _toggleLike,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      color: theme.colorScheme.onPrimary,
                      onPressed: () {},
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed:(){showProductForm(context);}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Add',
                        style: TextStyle( 
                          color: theme.colorScheme.onPrimary
                        )
                      ),
                      Icon(Icons.add, color: theme.colorScheme.onPrimary,)
                    ],
                  )
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$likes likes',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  widget.productData.name,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.productData.description,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4.0),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Add a comment', // Provide a fallback if description is null
                    style: TextStyle(
                      color: Colors.grey[400], // Use indexed access for color shades
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
