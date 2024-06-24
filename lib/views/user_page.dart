import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prototype_ss/widgets/search_grid_item.dart';

class UserPage extends StatefulWidget {
  final String userId;

  const UserPage({super.key, required this.userId});

  @override
  State<UserPage> createState() {
    return _UserPage();
  }
}

class _UserPage extends State<UserPage> {
  String profileLink = 'https://free-icon-rainbow.com/i/icon_01993/icon_019930_256.jpg';
  String username = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
    fetchUserProducts();
  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<void> getUserInfo() async {
    try {
      const Duration timeoutDuration = Duration(seconds: 10);
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get()
          .timeout(timeoutDuration);

      if (querySnapshot.exists) {
        if (mounted) {
          setState(() {
            username = querySnapshot.data()?['name'] ?? '';
            profileLink = querySnapshot.data()?['profileLink'] ?? profileLink;
          });
        }
      } else {
        if (mounted) {
          print('Document does not exist');
        }
      }
    } on TimeoutException catch (_) {
      print('Timeout occurred');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchUserProducts() async {
    await Provider.of<ProductsProvider>(context, listen: false).fetchUserProducts(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    final userProducts = Provider.of<ProductsProvider>(context).userProducts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(profileLink),
                ),
                const SizedBox(width: 8.0),
                Column(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Posts: ${userProducts.length}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 0.0,
                  ),
                  itemCount: userProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 3,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: SearchGridItem(productData: userProducts[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
