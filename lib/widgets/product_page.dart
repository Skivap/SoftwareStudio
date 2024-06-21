import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/widgets/product.dart';
import 'package:prototype_ss/provider/product_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  var selectIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        productsProvider.fetchProducts();
      }
    });
  }

  void _applyFilters() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    productsProvider.filterProducts(
      widget.searchQuery,
      widget.categoryFilters,
      widget.styleFilters,
      widget.seasonFilters,
    );
  }
    

  @override
  Widget build(BuildContext context) {

    final productsProvider = Provider.of<ProductsProvider>(context);
    var products = productsProvider.products;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
            return StaggeredGrid.count(
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              children: products.map((product) {
                return StaggeredGridTile.count(
                  crossAxisCellCount: 1 ,
                  mainAxisCellCount: 1,
                  child: ProductCard(
                    productData: product,
                  ),
                );
              }).toList(),
            );
          }
        ),
      );
  }
}
