import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/widgets/search_grid_item.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/provider/product_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SearchGrid extends StatefulWidget {
  final String searchQuery;
  const SearchGrid({
    super.key, 
    this.searchQuery = '', 
  });

  @override
  State<SearchGrid> createState() {
    return _SearchGridState();
  }
}

class _SearchGridState extends State<SearchGrid> {
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
      if(mounted){
      setState(() {
        _isLoadingMore = true;
      });
      }

      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      productsProvider.fetchProducts().then((_) {
        if(mounted){
        setState(() {
          _isLoadingMore = false;
        });
        }
      });
    }
  }

  void _applyFilters() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    productsProvider.filterProducts(widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    final productsProvider = Provider.of<ProductsProvider>(context);
    var products = productsProvider.products;
    
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return AnimationLimiter(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0.0,
                  mainAxisSpacing: 0.0,
                ),
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 3,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: SearchGridItem(productData: products[index])
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}