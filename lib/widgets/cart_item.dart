import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

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
                  productInfo['description'] ?? 'Loading d  escription...',
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
    return InkWell(
      onTap: () {
        _showProductDetails(context);
      },
      hoverColor: Color.fromRGBO(0, 0, 0, 255),
      child: Container(
        margin: const EdgeInsets.only(left:50, bottom: 20),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   // borderRadius: BorderRadius.circular(10.0),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.5),
        //       spreadRadius: 5,
        //       blurRadius: 7,
        //       offset: const Offset(0, 3),
        //     ),
        //   ],
        // ),
        child: 
        Column(
          children: [
            Row(
            children: [
              Container(
                decoration:const BoxDecoration(
                  color: Colors.white
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100, 
                          height: 100, 
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        ),
                        Transform.rotate(
                          angle: -math.pi / 16,
                            child: Container(
                            width: 100, 
                            height: 100, 
                            decoration: const BoxDecoration(
                              color: Colors.black,
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
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 200,
                child: Column(
                  children: [
                    Text(
                      productInfo['name'] ?? 'Loading...',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      indent: 30,
                      endIndent: 30,
                    ),  
                    Text(
                      productInfo.containsKey('price') ? '${productInfo['price']} NTD' : 'Loading...',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ),
          Container(height: 20  ,),
          const Divider(
            thickness: 4,
            indent: 80,
            endIndent: 80,
          )
          ]
        ),
      ),
    );
  }
}
