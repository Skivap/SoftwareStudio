import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String style;
  final String sellerID;
  final String price;
  final int likes;
  final String link;
  final List<dynamic> likedby;
  Product({
    required this.likes,
    required this.likedby,
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.style,
    required this.price,
    required this.sellerID, 
    required this.link,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    var a = data['price'];
    return Product(
      likes: data['likes'] ?? 0,
      likedby: data['likedby'] ?? [],
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      style: data['style'] ?? '',
      link: data['link'] ?? '',
      price: data['price'].toString(),
      sellerID: data['sellerId'] ?? '',
    );
  }
  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      likes: data['likes'] ?? 0,
      likedby: data['likedby'] ?? [],
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      style: data['style'] ?? '',
      link: data['link'] ?? '',
      price: data['price'].toString(),
      sellerID: data['sellerId'] ?? '',
    );
  }
}
