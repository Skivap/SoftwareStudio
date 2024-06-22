import 'package:flutter/material.dart';
import 'package:prototype_ss/widgets/search_grid.dart';
import 'package:prototype_ss/widgets/dropdown_menu.dart';

String _searchQuery = '';
List<String> _selectedCategoryFilters = [];
List<String> _selectedStyleFilters = [];
List<String> _selectedSeasonFilters = [];

Widget searchPage(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title:
        Column(
          children: [
            Transform.translate(
              offset: const Offset(0, 10),
              child: const Text(
                'Explore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Abhaya Libre SemiBold',
                  fontWeight: FontWeight.w600,
                  height: 3,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: const Divider(
                height: 20,
                thickness: 3  ,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
            ), 
          ]
        )
        ),
      body:
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: buildSearchBar(context, setState),
                ),
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
                   child: SearchGrid(
                     searchQuery: _searchQuery,
                     categoryFilters: _selectedCategoryFilters,
                     styleFilters: _selectedStyleFilters,
                     seasonFilters: _selectedSeasonFilters,
                   ),
                 ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      )
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
