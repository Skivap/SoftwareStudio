import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/model/product_model.dart';

class HomeProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchProducts() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').limit(10).get();
      _products.addAll(snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error loading more products: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
