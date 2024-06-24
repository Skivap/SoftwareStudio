import 'package:prototype_ss/model/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> _userProducts = [];

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;
  List<Product> get userProducts => _userProducts;

  Future<void> fetchProducts() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('products').get();
      _allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      _filteredProducts = List.from(_allProducts);
      notifyListeners();
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> fetchUserProducts(String userId) async {
    try {
      // Clear the previous user's products before fetching the new user's products
      _userProducts = [];
      Future.microtask(() => notifyListeners());

      var snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: userId)
          .get();
      _userProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print("Error fetching user products: $e");
    }
  }

  void cleanUserProducts() {
    _userProducts = [];
    Future.microtask(() => notifyListeners());
  }

  void filterProducts(String searchQuery) async {
    _filteredProducts = List.from(_allProducts);

    print("total = ${_allProducts.length}");

    if (searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    Future.microtask(() => notifyListeners());
  }
}
