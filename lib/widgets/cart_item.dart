import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> productInfo;
  final Map<String, dynamic> cartItemData;
  final void Function() removeFromCart;

  const CartItemCard({
    super.key,
    required this.productInfo,
    required this.cartItemData,
    required this.removeFromCart,
  });

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(15.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ClipRRect(
                    // borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      productInfo['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                      height: 450,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  productInfo['name'] ?? 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  productInfo.containsKey('price') ? '${productInfo['price']} NTD' : 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  productInfo['description'] ?? 'Loading description...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: removeFromCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Remove from Cart',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    return Container(
      margin: const EdgeInsets.only(left:50, bottom: 20),
      child: Column(
        children: [
          Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100, 
                        height: 100, 
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      Transform.rotate(
                        angle: -math.pi / 16,
                          child: Container(
                          width: 100, 
                          height: 100, 
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -math.pi / 32,
                        child: ClipRRect(
                          child: Image.network(
                            productInfo['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ]
                  ),
                ],
              ),
            ),
            Container(width: 20,),
            Container(
              padding: const EdgeInsets.all(8.0),
              width: 200,
              child: Column(
                children: [
                  Text(
                    productInfo['name'] ?? 'Loading...',
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary
                    ),
                  ),
                  const Divider(
                    indent: 30,
                    endIndent: 30,
                  ),  
                  Text(
                    productInfo.containsKey('price') ? '${productInfo['price']} NTD' : 'Loading...',
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  Container(height: 10,),
                  Row(
                    children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
    
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5, // Shadow depth
                          backgroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: theme.colorScheme.secondary, width: 3)
                          ), 
                        ),
                        child: Text(
                          'Try', 
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold
                          ),
                        ), 
                      ),
                    ),
                    Container(width: 20,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showProductDetails(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5, // Shadow depth
                          backgroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: theme.colorScheme.secondary, width: 3)
                          ), 
                        ),
                        child: Text(
                          'Info', 
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold
                          ),
                        ), 
                      ),
                    ),
                    ],
                  )
                ],
              ),
            ),
          ]
        ),
        const Divider(
          thickness: 4,
          indent: 80,
          endIndent: 80,
        )
        ]
      ),
    );
  }
}
