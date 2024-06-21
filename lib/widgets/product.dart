import 'package:flutter/material.dart';
import 'package:prototype_ss/model/product_model.dart';
import 'package:prototype_ss/provider/product_provider.dart';
import 'package:prototype_ss/widgets/buy_product_screen.dart';

class ProductCard extends StatefulWidget {
  final Product productData;
  final void Function(int) selectIdx;
  final int idItem;

  const ProductCard({
    Key? key,
    required this.productData,
    required this.selectIdx,
    required this.idItem,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {

  // void _showProductDetails(BuildContext context, Map<String, dynamic> productData) {
  //   showModalBottomSheet<dynamic>(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (context) {
  //       return FractionallySizedBox(
  //         heightFactor: 0.9,
  //         child: Padding(
  //           padding: const EdgeInsets.all(15.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Center(
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   child: Image.network(
  //                     productData['imageUrl'],
  //                     errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
  //                     fit: BoxFit.fill,
  //                     height: 450,
  //                     width: double.infinity,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 40),
  //               Text(
  //                 productData['name'],
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               Text(
  //                 '${productData['price']} NTD',
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               Text(
  //                 productData['description'] ?? 'No description available',
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () { // Close the bottom sheet
  //                   showDialog(
  //                     context: context,
  //                     builder: (context) => BuyScreen(productData: productData),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.purple,
  //                 ),
  //                 child: const Text(
  //                   'Buy',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Product productData = widget.productData;
    void Function(int) selectIdx = widget.selectIdx;
    int idItem = widget.idItem;

    return InkWell(
      onTap: () {
        selectIdx(idItem);
        // _showProductDetails(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Stack(
          children: [
            ClipRRect(
              // borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                productData.imageUrl,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10.0),
                color: Colors.black.withOpacity(0.5), // Optional: Add overlay for better text visibility
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    productData.name,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Make text color white for better contrast
                    ),
                  ),
                  Text(
                    '${productData.price} NTD',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white, // Make text color white for better contrast
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
