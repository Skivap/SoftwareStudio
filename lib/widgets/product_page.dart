import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:prototype_ss/widgets/product.dart';

class ProductPage extends StatefulWidget {
  final Axis scrollDirection;
  final String searchQuery;
  final List<String> categoryFilters;
  final List<String> styleFilters;
  final List<String> seasonFilters;

  const ProductPage({
    super.key, 
    this.scrollDirection = Axis.vertical, 
    this.searchQuery = '', 
    this.categoryFilters = const [], 
    this.styleFilters = const [], 
    this.seasonFilters = const []
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  var select_index = -1;
  void select_item_idx(int tt){
    setState(() {
      if(select_index == tt){
        select_index = -1;
      } else {
        select_index = tt;
      }
    });

  }
  int rounder_index(int idx, int n) {
    if(idx == -1) {
      return n;
    }
    int roundedIdx =  3 * ((idx + 3) / 3).floor();
    return roundedIdx > n ? n : roundedIdx;
  }

  @override
  Widget build(BuildContext context) {
    String searchQuery = widget.searchQuery;
    List<String> categoryFilters = widget.categoryFilters;
    List<String> styleFilters = widget.styleFilters;
    List<String> seasonFilters = widget.seasonFilters;
    // Axis scrollDirection = widget.scrollDirection;

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

            if (searchQuery.isNotEmpty) {
              products = products.where((product) {
                return product['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
                       product['description'].toLowerCase().contains(searchQuery.toLowerCase());
              }).toList();
            }

            if (categoryFilters.isNotEmpty) {
              products = products.where((product) {
                return categoryFilters.contains(product['category']);
              }).toList();
            }
            if (styleFilters.isNotEmpty) {
              products = products.where((product) {
                return styleFilters.contains(product['style']);
              }).toList();
            }
            if (seasonFilters.isNotEmpty) {
              products = products.where((product) {
                return seasonFilters.contains(product['season']);
              }).toList();
            }

            int n = rounder_index(select_index, products.length);
            List<Widget> gridChildrenFirstHalf = [];
            List<Widget> gridChildrenSecondHalf = [];

            if (n > 0 && products.length >= n) {
              for (int i = 0; i < n; i++) {  // Use index-based loop to access the index
                var product = products[i];
                gridChildrenFirstHalf.add(
                  ProductCard(
                    productData: product,
                    select_idx: select_item_idx,  // Pass a lambda that captures the index
                    id_item: i  // Pass the index number as id_item
                  )
                );
              }
            }

            if (n < products.length) {
              for (int i = n; i < products.length; i++) {  // Start from n to end of list
                var product = products[i];
                gridChildrenSecondHalf.add(
                  ProductCard(
                    productData: product,
                    select_idx: select_item_idx,  // Pass a lambda that captures the index
                    id_item: i  // Pass the index number as id_item
                  )
                );
              }
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: gridChildrenFirstHalf,
                  ),
                  if(select_index >= 0)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1000),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      child: select_index >= 0 ? Container(
                        key: ValueKey<int>(select_index),
                        color: Colors.grey[300],
                        height: 200,
                        child: Row(
                          children: [
                            ClipRRect(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Image.network(
                                  products[select_index]['imageUrl'],
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                  height: 200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ) : SizedBox(),  // Provide an empty SizedBox when select_index is not valid
                    ),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    shrinkWrap: true,
                    children: gridChildrenSecondHalf,
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
