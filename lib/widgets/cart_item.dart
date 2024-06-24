import 'package:flutter/material.dart';
import 'package:prototype_ss/model/product_model.dart';
import 'dart:math' as math;
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/provider/viton_provider.dart';
import 'package:prototype_ss/widgets/product.dart';
import 'package:provider/provider.dart';

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
  State<CartItemCard> createState() {
    return _CartItemCardState();
  }
}

class _CartItemCardState extends State<CartItemCard>  {
  late Product productData;
  late Map<String, dynamic> productInfo;
  late Map<String, dynamic> cartItemData;
  late void Function() removeFromCart;
  late String userId;
  late Map<String, dynamic> userData;

  @override
  void initState(){
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadData() async {
    productInfo = widget.productInfo;
    productData = Product.fromMap(productInfo);
    cartItemData = widget.cartItemData;
    removeFromCart = widget.removeFromCart;
    userId = widget.userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<VitonProvider>(context, listen: false);
        provider.loadData(userId, cartItemData['cartId']);
      }
    });
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

  void _showProductDetails(BuildContext context, ThemeData theme) {
    final provider = Provider.of<VitonProvider>(context, listen: false);
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (context){
        return ProductContent(productData: productData, showExitButton: true, showSwipeDelete: true,);
      }
    );
  }

  Widget showResponseWithFutureBuilder(ThemeData theme) {
    final provider = Provider.of<VitonProvider>(context, listen: true);

    String? vtonLink = provider.link_vton[cartItemData['cartId']];
    bool _isLoading = provider.isLoading[cartItemData['cartId']] ?? false;

    // print("$vtonLink, $_isLoading");
    if(vtonLink == null && _isLoading == false){
      return Container();
    }
    if(_isLoading){
      return const SizedBox(
        width: 150,
        height: 150,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.onPrimary, // Specify the color of the border
          width: 2.0, // Specify the width of the border
        ),
      // borderRadius: BorderRadius.circular(15.0), // This sets the radius of the border
      ),
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(15.0),
        child: Image.network(
          vtonLink ?? '',
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

  Future<bool> showUploadDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Image'),
          content: Text('Please upload your image of your full body'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Dismisses the dialog and returns false
              },
            ),
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop(true); // Dismisses the dialog and returns true
              },
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed by back button or tapping outside the dialog
  }

  void warning(BuildContext context, String error){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VitonProvider>(context, listen: false);
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
                      if (productInfo['imageUrl'] != null)
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
                              productInfo['imageUrl'],
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
                          if(provider.link_bd == null){
                            print("Need to Upload");
                            provider.uploadPictureFromCamera(context, warning, showUploadDialog);
                          }
                          else{
                            print("Generate");
                            provider.generate(cartItemData['cartId']);
                          }
                          
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
                          _showProductDetails(context, theme);
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
