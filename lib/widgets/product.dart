import 'package:flutter/material.dart';
import 'package:prototype_ss/model/product_model.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/views/user_page.dart';
import 'package:prototype_ss/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io' as io;

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
  String profileLink = '';
  String username = '';
  late int likes;
  bool isLiked = false; // Provide a default value for isLiked

  @override
  void initState() {
    super.initState();
    likes = widget.productData.likes;
    _initializeLikeState();
    getUserInfo(widget.productData.sellerID);
  }

  Future<void> _initializeLikeState() async {
    isLiked = await _firestoreService.hasLikedPost(widget.productData.id);
    if(mounted){ setState(() {}); }
  }

  void _toggleLike() async {
    final int previousLikes = likes;
    final bool previousIsLiked = isLiked;

    if(mounted){
      setState(() {
        isLiked = !isLiked;
        likes += isLiked ? 1 : -1;
      });
    }

    try {
      await _firestoreService.likePost(widget.productData.id, previousIsLiked);
    } catch (e) {
      if(mounted){
        setState(() {
          isLiked = previousIsLiked;
          likes = previousLikes;
        });
      }
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
            profileLink = querySnapshot.data()?['profileLink'] ?? '';
          });
        }
      } else {
        if (mounted) {
          print('Document does not exist');
        }
      }
    } on TimeoutException catch (_) {
      if(mounted){
        setState(() {
          username = 'Timeout';
        });
      }
      print('Timeout occurred');
    } catch (e) {
      if(mounted){
      setState(() {
        username = '$e';
      });
      }
      print('Error: $e');
    }
  }

  void addProduct(String userId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null){
      showErrorDialog(context, 'No user is signed in');
      return;
    }

    final String userId = user.uid;
    final CollectionReference cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart');

    try {
      final QuerySnapshot existingProduct = await cartRef
        .where('productId', isEqualTo: widget.productData.id)
        .limit(1)
        .get(); 
      
      if (existingProduct.docs.isEmpty){
        await cartRef.add({
          'productId': widget.productData.id,
          'productName': widget.productData.name
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to wardrobe')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product already in wardrobe')),
        );
      }
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product to wardrobe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;

    return SafeArea(
      child: Container(
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
            const SizedBox(height: 20,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPage(userId: widget.productData.sellerID),
                  ),
                );
              },
              child: Row(
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
                    backgroundImage: NetworkImage(profileLink.isNotEmpty ? profileLink : 'https://free-icon-rainbow.com/i/icon_01993/icon_019930_256.jpg'),
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
                    onPressed:(){addProduct(widget.productData.sellerID);}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Add',
                          style: TextStyle( 
                            color: theme.colorScheme.onPrimary,
                            fontSize: 15,
                          )
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 20)
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
                  const SizedBox(height: 20.0),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), 
                        color: theme.colorScheme.tertiary
                      ),
                      padding: const EdgeInsets.all(9),
                      child: InkWell(
                        onTap: () async {
                          if (widget.productData.link != '') {
                            await launchUrl(Uri.parse(widget.productData.link));
                          }
                        },
                        child: Text(
                          'Buy Product', 
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary, 
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}
