import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductPage extends StatefulWidget {
  
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPage();

}

class _ProductPage extends State<ProductPage>{

  int selectedIdx = 0;
  List<Color> colorList = [
    Colors.red, Colors.yellow, Colors.blue, Colors.green, Colors.black
  ];


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child:ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const Image(image: AssetImage("assets/images/sample_image.png")),
            )
          ),

          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIdx = index;
                    });
                  },
                  child: AnimatedContainer(
                    width: 40,
                    height: 40,
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorList[index],
                      border: Border.all(
                        color: Colors.black, //index == selectedIdx ? const Color.fromARGB(255, 8, 46, 91) : Colors.black,
                        width: index == selectedIdx ? 4 : 2 ,
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
          const SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  backgroundColor: Colors.orange[800], // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Button border radius
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white), // Add to Cart icon
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      'Try Virtually!',
                      style: TextStyle(color: Colors.white, fontSize: 16), // Button text style
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  backgroundColor: Colors.blue, // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Button border radius
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_shopping_cart, color: Colors.white), // Add to Cart icon
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white, fontSize: 16), // Button text style
                    ),
                  ],
                ),
              ),
            ]
          )
        ],
      )
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const ProductPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Widget ProductCard(String item, BuildContext context){
  return
  Container(
    margin: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: const Image(image: AssetImage("assets/images/sample_image.png"))
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$item\t20 NTD",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black
                    
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed :() => {
                    Navigator.of(context).push( _createRoute() )
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(8), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 188, 60, 103), // Choose your border color
                      width: 1, // Choose the border width
                    ),
                    elevation: 2, 
                    
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 6,
                      bottom: 6
                    ),
                    child: Text(
                      'More',
                      style: TextStyle(
                        color: Color.fromARGB(255, 188, 60, 103),
                        fontSize: 16, // Adjust font size as needed
                        fontWeight: FontWeight.bold, // Adjust font weight as needed
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}