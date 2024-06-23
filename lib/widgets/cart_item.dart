import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/api/viton_api.dart';
import 'package:prototype_ss/service/save_image.dart';
import 'package:prototype_ss/widgets/generate_text.dart';

class CartItemCard extends StatefulWidget {
  final Map<String, dynamic> productInfo;
  final Map<String, dynamic> cartItemData;
  final void Function() removeFromCart;
  final String userId;

  const CartItemCard({
    super.key,
    required this.productInfo,
    required this.cartItemData,
    required this.removeFromCart,
    required this.userId
  });

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>  {
  late Map<String, dynamic> productInfo;
  late Map<String, dynamic> cartItemData;
  late void Function() removeFromCart;
  late String userId;

  bool _isMounted = false;
  String? link_vton;

  @override
  void initState(){
    super.initState();
    _loadData();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _loadData() {
    productInfo = widget.productInfo;
    cartItemData = widget.cartItemData;
    removeFromCart = widget.removeFromCart;
    userId = widget.userId;
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the data has changed, then update
    if (oldWidget.productInfo != widget.productInfo ||
        oldWidget.cartItemData != widget.cartItemData) {
      _loadData();
    }
  }

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
                      link_vton ?? productInfo['imageUrl'] ?? '',
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

  bool _isLoading = false;

  void generate() async {

    try{
      if(productInfo['viton'] != null && productInfo['viton'] != "") return;
      if(_isLoading) return;

      if(_isMounted){
        setState(() {
          _isLoading = true;
        });
      }

      FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemData['cartId'])
        .update({
          "url": "generating"
        });
        
      var result = await fetchVitonResult(
        "https://thumbs.dreamstime.com/b/cheerful-casual-indian-man-full-body-isolated-white-photo-37914698.jpg",
        "https://img.freepik.com/free-photo/blue-t-shirt_125540-727.jpg"
      );

      FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemData['cartId'])
        .update({
          "url": result
        });
      
      if(_isMounted){
        setState(() {
          _isLoading = false;
          print(result);
        });
      }
    }
    catch(e){
      print("error as $e");
      return;
    }
  }

  Widget showResponseWithFutureBuilder(ThemeData theme) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemData['cartId'])
        .get()
        .timeout(const Duration(seconds: 10)),
      builder: (context, snapshot) {
        if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          print("Error fetching document: ${snapshot.error}");
          return Container();
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          print("Document does not exist or is empty.");
          return Container();
        }

        Map<String, dynamic>? documentData = snapshot.data!.data() as Map<String, dynamic>?;
        if (documentData == null || documentData['url'] == null || documentData['url'] == "") {
          return Container();
        } else {
          link_vton = documentData['url'];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.onPrimary, // Specify the color of the border
                width: 2.0, // Specify the width of the border
              ),
            //   borderRadius: BorderRadius.circular(15.0), // This sets the radius of the border
            ),
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                documentData['url'] ?? '',
                fit: BoxFit.cover,
                width: 150,
                height: 150,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // image has loaded
                  } else {
                    return Center(
                      child: SizedBox(
                        width: 150, // Explicit width for the loader
                        height: 150, // Explicit height for the loader
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  } 
                }
              ),
              
            ),
          );
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    return Container(
      margin: const EdgeInsets.only(left:20, bottom: 20),
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
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: math.pi/64,
                        child: Container(
                          width: 150, 
                          height: 150, 
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            border: Border.all(
                              color: theme.colorScheme.onPrimary, // Specify the color of the border
                              width: 2.0, // Specify the width of the border
                            ),
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -math.pi / 16,
                          child: Container(
                          width: 150, 
                          height: 150, 
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            border: Border.all(
                              color: theme.colorScheme.onPrimary, // Specify the color of the border
                              width: 2.0, // Specify the width of the border
                            ),
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -math.pi / 32,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.onPrimary, // Specify the color of the border
                              width: 2.0, // Specify the width of the border
                            ),
                          ),
                          child: ClipRRect(
                            child: Image.network(
                              productInfo['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: SizedBox(
                                    width: 150, // Explicit width for the loader
                                    height: 150, // Explicit height for the loader
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      showResponseWithFutureBuilder(theme),
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
                          generate();
                        },
                        style: ElevatedButton.styleFrom(
                          // elevation: 5, // Shadow depth
                          backgroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            // side: BorderSide(color: theme.colorScheme.secondary, width: 3)
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
                          // elevation: 5, // Shadow depth
                          backgroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            // side: BorderSide(color: theme.colorScheme.secondary, width: 3)
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
        Container(height: 20,),
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
