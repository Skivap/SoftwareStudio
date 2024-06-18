import 'package:flutter/material.dart';
import 'package:prototype_ss/widgets/product_page.dart';

String _searchQuery = '';

Widget searchPage(BuildContext context) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 20,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Home Page Sucks? Try Search!",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10.0),
            buildSearchBar(context, setState),
            const SizedBox(height: 40),
            Expanded(
              child: ProductPage(searchQuery: _searchQuery),
            ),
            const SizedBox(height: 120),
          ],
        ),
      );
    },
  );
}

Widget buildSearchBar(BuildContext context, StateSetter setState) {
  return TextField(
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.search),
      hintText: 'Search products...',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    onChanged: (query) {
      setState(() {
        _searchQuery = query;
      });
    },
  );
}
