import 'package:flutter/material.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/widgets/search_grid.dart';
import 'package:prototype_ss/widgets/dropdown_menu.dart';
import 'package:provider/provider.dart';

String _searchQuery = '';
List<String> _selectedCategoryFilters = [];
List<String> _selectedStyleFilters = [];
List<String> _selectedSeasonFilters = [];

Widget searchPage(BuildContext context) {
  final theme = Provider.of<ThemeProvider>(context).theme;
  return Scaffold(
    appBar: AppBar(
      backgroundColor: theme.colorScheme.secondary,
      title: Text(
        'Explore',
        style: TextStyle(
          fontFamily: 'Abhaya Libre SemiBold', 
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    ),
    backgroundColor: theme.colorScheme.primary,
    body: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          decoration: BoxDecoration(color: theme.colorScheme.primary),
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
  final theme = Provider.of<ThemeProvider>(context).theme;
  return TextField(
    style: TextStyle(color: theme.colorScheme.onPrimary),
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      hintText: 'Search products...',
      hintStyle: TextStyle(
        color: theme.colorScheme.onPrimary
      ),
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
