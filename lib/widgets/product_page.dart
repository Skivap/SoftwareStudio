import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/widgets/product.dart';
import 'package:prototype_ss/provider/product_provider.dart';

class ProductPage extends StatefulWidget {
  final Axis scrollDirection;
  final String searchQuery;
  final List<String> categoryFilters;
  final List<String> styleFilters;
  final List<String> seasonFilters;
  final int mode;
  final int rows;
  const ProductPage({
    Key? key, 
    this.scrollDirection = Axis.vertical, 
    this.rows = 1,
    this.mode = 0,
    this.searchQuery = '', 
    this.categoryFilters = const [], 
    this.styleFilters = const [], 
    this.seasonFilters = const [],
  }) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        productsProvider.fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      productsProvider.fetchProducts().then((_) {
        setState(() {
          _isLoadingMore = false;
        });
      });
    }
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
    double myHeight = MediaQuery.of(context).size.height;

    final productsProvider = Provider.of<ProductsProvider>(context);
    var products = productsProvider.products;
    return Container(
      color:Colors.black,
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
      
            return GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.rows,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
                
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                if(widget.mode == 0){
                  return ProductContent(productData: products[index]);
                }
                else{
                  return ProductCard(productData: products[index]);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
