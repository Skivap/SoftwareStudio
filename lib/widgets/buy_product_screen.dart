import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype_ss/widgets/numericStepButton.dart';

class BuyScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  const BuyScreen({super.key, required this.productData});

  @override
  State<BuyScreen> createState() {
    return _BuyScreen();
  }
}

class _BuyScreen extends State<BuyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _quantity = 1;
  bool _isLoading = false;

  String _generateIdempotencyKey(String userId, String productId) {
    return 'addToCart_${userId}_${productId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _addToCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String productId = widget.productData['productId'];
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
            'price': widget.productData['price'],
            'name': widget.productData['name']
          });
          transaction.set(idempotencyRef, {
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          print('Idempotency key already exists');
        }
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding to cart: $e');
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Trendify Buy'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        widget.productData['imageUrl'],
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.productData['name']}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.productData['price']} NTD',
                            textAlign: TextAlign.right,
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
                Flexible(
                  child: Text(
                    widget.productData['description'] ?? 'No description provided',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                NumericStepButton(
                  key: UniqueKey(),
                  minValue: 1,
                  maxValue: widget.productData['availableStock'] ?? 10,
                  initialValue: _quantity, // Pass the initial quantity
                  onChanged: (value) {
                    setState(() {
                      _quantity = value;
                    });
                  },
                ),
              ],
            ),
      actions: _isLoading
          ? null // Disable buttons while loading
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _addToCart,
                child: const Text('Add to Cart'),
              ),
            ],
    );
  }
}
