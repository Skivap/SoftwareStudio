import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/widgets/product.dart';


class ProductPage extends StatelessWidget {
  final Axis scrollDirection;

  const ProductPage({super.key, this.scrollDirection = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data: ${snapshot.error}'));
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            List<Map<String, dynamic>> products = snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data['productId'] = doc.id;
              return data;
            }).toList();

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: scrollDirection == Axis.vertical ? 2 : 1,
                childAspectRatio: 1,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              scrollDirection: scrollDirection,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  productData: products[index],
                );
              },
            );
          }
        },
      ),
    );
  }
}
