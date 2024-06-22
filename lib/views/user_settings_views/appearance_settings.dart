import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/model/themes.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppearancePage extends StatefulWidget {
  @override
  _AppearancePageState createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  String selectedTheme = '';

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    selectedTheme = themeProvider.getStringName();
  }

  Future<void> updateUserTheme(String themeName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'theme': themeName});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme updated successfully')),
        );
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update theme')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildThemeTile('Classic Light Theme', classicLightTheme, themeProvider),
          buildThemeTile('Classic Dark Theme', classicDarkTheme, themeProvider),
          buildThemeTile('Light Forest Theme', lightForestTheme, themeProvider),
          buildThemeTile('Sunny Beach Theme', sunnyBeachTheme, themeProvider),
          buildThemeTile('Twillight Theme', twillightTheme, themeProvider),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              themeProvider.setThemeByName(selectedTheme);
              await updateUserTheme(selectedTheme);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  String _themeSwitcher(String themename){
    switch(themename){
      case ('Classic Light Theme'):
        return 'classicLightTheme';
      case ('Classic Dark Theme'):
        return 'classicDarkTheme';
      case ('Light Forest Theme'):
        return 'lightForestTheme';
      case ('Sunny Beach Theme'):
        return 'sunnyBeachTheme';
      case ('Twillight Theme'):
        return 'twillightTheme';
      default:
        return 'classicLightTheme';
    }
  }

  Widget buildThemeTile(String title, ThemeData theme, ThemeProvider themeProvider) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: selectedTheme == _themeSwitcher(title)
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: () {
          setState(() {
            selectedTheme = _themeSwitcher(title);
          });
        },
      ),
    );
  }
}
