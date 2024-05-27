import 'package:flutter/material.dart';
import 'package:prototype_ss/widgets/NumericStepButton.dart';

class BuyScreen extends StatefulWidget{
  final Map<String, dynamic> productData;
  const BuyScreen ({super.key, required this.productData});

  @override
  State<BuyScreen> createState(){
    return _BuyScreen();
  }
}

class _BuyScreen extends State<BuyScreen>{
  int _quantity = 1;

  void _addToCart() {
    // String userId = FirebaseAuth.instance.currentUser!.uid;
    // FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').add({
    //   'productId': widget.productData['productId'],
    //   'quantity': _quantity,
    //   'price': widget.productData['price'],
    // });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: const Text('Trendify Buy'),
      content: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.productData['imageUrl'],
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                )
              ),
              Flexible(
                child: Column(
                  children: [
                    Text(
                      '${widget.productData['name']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(
                      '${widget.productData['price']} NTD',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              )
            ],
          ),
          Flexible(
            child: Text(
              widget.productData['description'] ?? 'No description provided',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              )
            ),
          ),
          const SizedBox(height: 20,),
          NumericStepButton(
            key: UniqueKey(), 
            minValue: 1,
            maxValue: widget.productData['availableStock'],
            onChanged: (value) => {
            setState(() {
              _quantity = value;
            })
          })
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _addToCart(),
          child: const Text('Add to Cart'),
        )
      ],
    );
  }
}