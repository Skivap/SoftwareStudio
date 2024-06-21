import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prototype_ss/model/product_model.dart';
import 'package:prototype_ss/provider/product_provider.dart';
import 'package:prototype_ss/widgets/buy_product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ProductContent extends StatefulWidget {
  final Product productData;

  const ProductContent({
    Key? key,
    required this.productData,
  }) : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<ProductContent> {
  String imageLink = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    
    getUserInfo(widget.productData.sellerID);
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
      username = 'Timeout';
      print('Timeout occurred');
    } catch (e) {
      username = '$e';
      print('Error: $e');
    }
  }

  
  

  @override
  Widget build(BuildContext context) {
    Product productData = widget.productData;

    return InkWell(
      onTap: () {
        
      },
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(imageLink.isNotEmpty ? imageLink : 'assets/images/logo.png'), // Fallback image
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  productData.imageUrl,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 8000, // Adjust the height here
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      productData.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${productData.price} NTD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      productData.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'add a coment', // Provide a fallback if description is null
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
      ),
    );
  }
}
