// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_ss/widgets/cart_item.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late User? _user;
  late String _userId;
  bool isLoading = true;
  String errorMessage = '';
  late List<Map<String, dynamic>> cartItems = [];
  late Map<String, dynamic> productInfo = {};

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userId = _user?.uid ?? '';
    getShoppingCart();
  }

  void getShoppingCart() async {
    try {
      const Duration timeoutDuration = Duration(seconds: 10);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .get()
          .timeout(timeoutDuration);

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            cartItems = querySnapshot.docs
                .where((doc) => doc.id != 'defaultCart')
                .map((doc) => {
                  'cartId': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
                .toList();
            isLoading = false;
          });
          await fetchProductInfo();
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'No cartItems found';
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Firestore query timed out';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error fetching data from Firestore: $e';
        });
      }
    }
  }

  Future<void> fetchProductInfo() async {
    try {
      List<String> productIds = cartItems.map((item) => item['productId'] as String).toList();
      if (productIds.isEmpty) {
        // If productIds is empty, update the state to reflect no products found
        if (mounted) {
          setState(() {
            productInfo = {};
          });
        }
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();
      Map<String, dynamic> data = {};
      for (var doc in querySnapshot.docs) {
        data[doc.id] = doc.data();
      }
      if (mounted) {
        setState(() {
          productInfo = data;
        });
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  void removeFromCart(String cartId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(cartId)
          .delete();
      if (mounted) {
        setState(() {
          cartItems.removeWhere((item) => item['cartId'] == cartId);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
        ),
      );
    } catch (e) {
      print('Error removing item from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error removing item from cart'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    //double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title:
        Column(
          children: [
            Transform.translate(
              offset: const Offset(0, 10),
              child: const Text(
                'Try On',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Abhaya Libre SemiBold',
                  fontWeight: FontWeight.w600,
                  height: 3,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: const Divider(
                height: 20,
                thickness: 3  ,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
            ), 
          ]
        )
        ),
      body:

      isLoading ? const Center(child: CircularProgressIndicator()) :
      errorMessage.isNotEmpty ? Center(child: Text(errorMessage)) :
      cartItems.isNotEmpty ? 
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.only(top: 30),
            height: myHeight * 0.92,
            
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> cartItem = cartItems[index];
                String cartId = cartItem['cartId'];
                String productId = cartItem['productId'];
                Map<String, dynamic> productData = productInfo[productId] ?? {};
                return CartItemCard(
                  productInfo: productData,
                  cartItemData: cartItem,
                  removeFromCart: () {
                    removeFromCart(cartId); 
                    Navigator.pop(context);
                  },
                );
              },
            ),

          ),
        ):
        const Center(
          child: Text(
            'Your Shopping Cart is empty. Explore our items!',
          ),
        )
    );
  }
}
