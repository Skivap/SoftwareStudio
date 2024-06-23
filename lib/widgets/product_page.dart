import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/widgets/product.dart';
import 'package:prototype_ss/provider/product_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key
  });

  @override
  State<ProductPage> createState() {
    return _ProductPageState();
  }
}

class _ProductPageState extends State<ProductPage> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  bool _isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _isMounted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        productsProvider.fetchProducts().then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isMounted = false;
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (!_isLoadingMore) {
      if(_isMounted){
        setState(() {
          _isLoadingMore = true;
        });
      }

      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      productsProvider.fetchProducts().then((_) {
        if(_isMounted){
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    final productsProvider = Provider.of<ProductsProvider>(context);
    var products = (productsProvider.products);

    return Container(
      color: theme.colorScheme.primary,
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.extentAfter < 500) {
                      _loadMoreProducts();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          child: FadeInAnimation(
                            child: ProductContent(productData: products[index])
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            if (_isLoadingMore)
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width / 2 - 15,
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
