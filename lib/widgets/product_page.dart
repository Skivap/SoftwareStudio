import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';
import 'dart:async';

class ProductPage extends StatefulWidget {
  final Axis scrollDirection;
  const ProductPage({super.key, this.scrollDirection = Axis.vertical});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getProductData();
  }

  void getProductData() async {
    try {
      const Duration timeoutDuration = Duration(seconds: 10);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get()
          .timeout(timeoutDuration); 

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          products = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No products found';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.scrollDirection == Axis.vertical ? 2 : 1,
        childAspectRatio: 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      scrollDirection: widget.scrollDirection,
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(productData: products[index]);
      },
    );
  }
}
