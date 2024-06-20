import 'package:flutter/material.dart';

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

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
      widget.onSelectionChanged(_selectedItems);
    });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () {
            _showMultiSelect(context);
          },
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
          ),
        ),
        Wrap(
          children: _selectedItems.map((item) {
            return Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  _selectedItems.remove(item);
                  widget.onSelectionChanged(_selectedItems);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
