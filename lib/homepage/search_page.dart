import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:prototype_ss/product.dart';

List<String> itemList = ['One', 'Two', 'Three', 'Four','One', 'Two', 'Three'];

Widget search_page(BuildContext context){
  return 
  Padding(
    padding: const EdgeInsets.only(
      left: 8.0,
      right: 8.0,
      top: 20,

    ),
    child: ListView(

        
        children: [

        const SizedBox(height: 10.0),
        
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Home Page Sucks? Try Search!",
            style: TextStyle(
              fontSize: 20
            ),
          ),
        ),

        const SizedBox(height: 10.0),
        
        Search_Bar(),
    
        const SizedBox(height: 40),

        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            for(String item in itemList)
            ProductCard(item, context)
          ],
        ),
        const SizedBox(height: 120),
      ],
    ),
    
  );
}

Widget Search_Bar(){
  return SearchAnchor(
    builder: (BuildContext context, SearchController controller) {
      return SearchBar(
        controller: controller,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onTap: () {
          controller.openView();
        },
        onChanged: (_) {
          controller.openView();
        },
        leading: const Icon(Icons.search),
        trailing: <Widget>[
          Tooltip(
            message: 'Change brightness mode',
            child: IconButton(
              // isSelected: isDark,
              onPressed: () {
                // setState(() {
                //   isDark = !isDark;
                // });
              },
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: const Icon(Icons.brightness_2_outlined),
            ),
          )
        ],
      );
    }, suggestionsBuilder:
            (BuildContext context, SearchController controller) {
      return List<ListTile>.generate(5, (int index) {
        final String item = 'item $index';
        return ListTile(
          title: Text(item),
          onTap: () {
            // setState(() {
            //   controller.closeView(item);
            // });
          },
        );
      });
  });
}