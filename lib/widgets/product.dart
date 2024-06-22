import 'package:flutter/material.dart';
import 'package:prototype_ss/model/product_model.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:provider/provider.dart';

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
                backgroundImage: NetworkImage(imageLink.isNotEmpty ? imageLink : 'assets/images/logo.png'),
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
                  onPressed: () => {

                  }, 
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
