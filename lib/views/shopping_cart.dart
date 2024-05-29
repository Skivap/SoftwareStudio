import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_ss/widgets/cart_item.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({Key? key});

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
        setState(() {
          cartItems = querySnapshot.docs
              .where((doc) => doc.id != 'defaultCart')
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          isLoading = false;
        });
        await fetchProductInfo();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No cartItems found';
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
        errorMessage = 'Firestore query timed out';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data from Firestore: $e';
      });
    }
  }

  Future<void> fetchProductInfo() async {
    try {
      List productIds = cartItems.map((item) => item['productId']).toList();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();
      Map<String, dynamic> data = {};
      querySnapshot.docs.forEach((doc) {
        data[doc.id] = doc.data();
      });
      setState(() {
        productInfo = data;
      });
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  void removeFromCart(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(productId)
          .delete();
      setState(() {
        cartItems.removeWhere((item) => item['productId'] == productId);
      });
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> cartItem = cartItems[index];
        String productId = cartItem['productId'];
        Map<String, dynamic> productData = productInfo[productId] ?? {};
        return CartItemCard(
          productInfo: productData,
          cartItemData: cartItem,
          removeFromCart: removeFromCart,
        );
      },
    );
  }
}
