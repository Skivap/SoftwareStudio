import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/widgets/product.dart';
import 'package:prototype_ss/provider/home_page_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _isMounted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final productsProvider = Provider.of<HomeProductsProvider>(context, listen: false);
        productsProvider.fetchProducts();
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
    if (!_isLoadingMore && _isMounted) {
      setState(() {
        _isLoadingMore = true;
      });

      final productsProvider = Provider.of<HomeProductsProvider>(context, listen: false);
      productsProvider.loadMoreProducts().then((_) {
        if (_isMounted) {
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
    final productsProvider = Provider.of<HomeProductsProvider>(context);
    var products = productsProvider.products;

    return Container(
      color: theme.colorScheme.primary,
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: Stack(
          children: [
            productsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
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
                              child: ProductContent(productData: products[index], isWardrobe: false, isHome: true),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            if (productsProvider.isLoadingMore)
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
