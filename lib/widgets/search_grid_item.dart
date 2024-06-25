import 'package:flutter/material.dart';
import 'package:prototype_ss/model/product_model.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/widgets/product.dart';
import 'package:provider/provider.dart';
class SearchGridItem extends StatefulWidget {
  final Product productData;

  const SearchGridItem({
    super.key,
    required this.productData,
  });

  @override
  State<SearchGridItem> createState() {
    return _SearchGridItemState();
  }
}

class _SearchGridItemState extends State<SearchGridItem> {

  void _showProductDetails(BuildContext context, Product productData) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return ProductContent(productData: productData, showExitButton: true, isWardrobe: false, isHome: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Product productData = widget.productData;
    final theme = Provider.of<ThemeProvider>(context).theme;

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: InkWell(
        onTap: () {
          _showProductDetails(context, productData);
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
                      style:  TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiary, 
                      ),
                    ),
                    Text(
                      '${productData.price} NTD',
                      textAlign: TextAlign.left,
                      style:  TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}