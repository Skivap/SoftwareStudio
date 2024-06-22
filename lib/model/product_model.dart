import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String style;
  final String season;
  final String sellerID;
  final String price;
  final int likes;
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
    required this.season,
    required this.price,
    required this.sellerID,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    var a = data['price'];
    print(a.runtimeType);
    return Product(
      likes: data['likes'] ?? 0,
      likedby: data['likedby'] ?? [],
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      style: data['style'] ?? '',
      season: data['season'] ?? '',
      price: data['price'].toString(),
      sellerID: data['sellerId'] ?? '',
    );
  }
}
