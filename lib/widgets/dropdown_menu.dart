import 'package:flutter/material.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class DropdownMultiMenu extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(List<String>) onSelectionChanged;

  const DropdownMultiMenu({
    super.key, 
    required this.title,
    required this.items,
    required this.onSelectionChanged,
  });

  @override
  State<DropdownMultiMenu> createState() {
    return _DropdownMultiMenuState();
  }
}

class _DropdownMultiMenuState extends State<DropdownMultiMenu> {
  final List<String> _selectedItems = [];

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _itemChange(String itemValue, bool isSelected) {
    if(_isMounted){
      setState(() {
        if (isSelected) {
          _selectedItems.add(itemValue);
        } else {
          _selectedItems.remove(itemValue);
        }
        widget.onSelectionChanged(_selectedItems);
      });
    }
  }

  void _showMultiSelect(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.items.map((item) {
                return CheckboxListTile(
                  value: _selectedItems.contains(item),
                  title: Text(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? isChecked) {
                    _itemChange(item, isChecked!);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiary
          ),
          onPressed: () {
            _showMultiSelect(context);
          },
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
        ),
        Wrap(
          children: _selectedItems.map((item) {
            return Chip(
              label: Text(item, style: TextStyle(color: theme.colorScheme.onPrimary),),
              onDeleted: () {
                if(_isMounted){
                  setState(() {
                    _selectedItems.remove(item);
                    widget.onSelectionChanged(_selectedItems);
                  });
                }
                
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
