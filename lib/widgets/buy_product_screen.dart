// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype_ss/model/product_model.dart';

class BuyScreen extends StatefulWidget {
  final Product productData;
  const BuyScreen({super.key, required this.productData});

  @override
  State<BuyScreen> createState() {
    return _BuyScreen();
  }
}

class _BuyScreen extends State<BuyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _quantity = 1;
  bool _isLoading = false;
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


  String _generateIdempotencyKey(String userId, String productId) {
    return 'addToCart_${userId}_${productId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _addToCart() async {
    if(_isMounted){
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String productId = widget.productData.id;
      String idempotencyKey = _generateIdempotencyKey(userId, productId);

      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentReference idempotencyRef = _firestore.collection('idempotencyKeys').doc(idempotencyKey);
      DocumentReference cartRef = userRef.collection('cart').doc();

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot idempotencySnapshot = await transaction.get(idempotencyRef);
        if (!idempotencySnapshot.exists) {
          transaction.set(cartRef, {
            'productId': productId,
            'quantity': _quantity,
            'price': widget.productData.price,
            'name': widget.productData.name,
            'url': null

          });
          transaction.set(idempotencyRef, {
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          print('Idempotency key already exists');
        }
      });

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding to cart: $e');
    } finally {
      if(_isMounted){
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 300,
        height: 400,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          widget.productData.imageUrl,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          fit: BoxFit.cover,
                          height: 100,
                          width: 100,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productData.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '${widget.productData.price} NTD',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.productData.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // NumericStepButton(
                  //   key: UniqueKey(),
                  //   minValue: 1,
                  //   maxValue: widget.productData. ?? 10,
                  //   initialValue: _quantity,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _quantity = value;
                  //     });
                  //   },
                  // ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _addToCart,
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }
}