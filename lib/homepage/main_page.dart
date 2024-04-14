import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:prototype_ss/product.dart';

var headerStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 30,
);

List<String> itemList = ['One', 'Two', 'Three', 'Four'];

Widget main_page(context){
  return ListView(
    padding: EdgeInsets.all(15),
    children: <Widget>[
      Container(
        height: 200,
        child: const Positioned(
          child: Image(
            image: AssetImage("assets/images/banner.jpg"),
            fit: BoxFit.fill,
          ),
        ),
      ),

      const SizedBox(height: 20.0),

      Text(
          "Recommended For You",
          style: headerStyle,
      ),

      const SizedBox(height: 4.0),
      
      Container(
        height: 350,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for(String item in itemList)
            SizedBox(
              width: 250,
              height: 320,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ProductCard(item, context)
              )
            ),
          ],
        ),
      ),

      const SizedBox(height: 20.0),

      Text(
          "Trending Right Now",
          style: headerStyle,
      ),

      const SizedBox(height: 4.0),
      
      Container(
        height: 350,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for(String item in itemList)
            SizedBox(
              width: 250,
              height: 320,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ProductCard(item, context)
              )
            ),
          ],
        ),
      ),

      const SizedBox(height: 100.0),
    ],
  );
}

