import 'package:flutter/material.dart';
import 'package:prototype_ss/widgets/product_page.dart';
import 'package:prototype_ss/widgets/dropdown_menu.dart';

String _searchQuery = '';
List<String> _selectedCategoryFilters = [];
List<String> _selectedStyleFilters = [];
List<String> _selectedSeasonFilters = [];

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
            const SizedBox(height: 5.0),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Home Page Sucks? Try Search!",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10.0),
            buildSearchBar(context, setState),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: DropdownMultiMenu(
                    title: 'Category', 
                    items: const ['Hats', 'Accessories', 'Tops', 'Bottoms', 'Shoes'], 
                    onSelectionChanged: (selectedFilters){
                      setState( () {
                        _selectedCategoryFilters = selectedFilters;
                      });
                    }
                  ),
                ),
                Flexible(
                  child: DropdownMultiMenu(
                    title: 'Style', 
                    items: const [
                      'Korean', 'Gorp', 
                      'Street', 'Business', 
                      'Formal', 'Y2K', 
                      'Old Money', 'Grunge',
                      'Starboy', 'Beach',
                      'Minimalist', 'Soft'
                    ], 
                    onSelectionChanged: (selectedFilters){
                      setState( () {
                        _selectedStyleFilters = selectedFilters;
                      });
                    }
                  ),
                ),
                Flexible(
                  child: DropdownMultiMenu(
                    title: 'Season', 
                    items: const ['Spring', 'Summer', 'Fall', 'Winter'], 
                    onSelectionChanged: (selectedFilters){
                      setState( () {
                        _selectedSeasonFilters = selectedFilters;
                      });
                    }
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ProductPage(
                searchQuery: _searchQuery,
                categoryFilters: _selectedCategoryFilters,
                styleFilters: _selectedStyleFilters,
                seasonFilters: _selectedSeasonFilters,
              ),
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
      prefixIcon: const Icon(Icons.search),
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
