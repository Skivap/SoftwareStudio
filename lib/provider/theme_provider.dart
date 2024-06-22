import 'package:flutter/material.dart';
import 'package:prototype_ss/model/themes.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _selectedTheme;

  ThemeProvider({String initialTheme = 'classicLightTheme'}) {
    setThemeByName(initialTheme);
  }

  ThemeData get theme => _selectedTheme;

  String getStringName() {
    if (_selectedTheme == classicLightTheme) {
      return 'classicLightTheme';
    } else if (_selectedTheme == classicDarkTheme) {
      return 'classicDarkTheme';
    } else if (_selectedTheme == lightForestTheme) {
      return 'lightForestTheme';
    } else if (_selectedTheme == sunnyBeachTheme) {
      return 'sunnyBeachTheme';
    } else if (_selectedTheme == twillightTheme) {
      return 'twillightTheme';
    } else {
      return 'classicLightTheme';
    }
  }

  void setThemeByName(String themeName) {
    switch (themeName) {
      case 'classicLightTheme':
        _selectedTheme = classicLightTheme;
        break;
      case 'classicDarkTheme':
        _selectedTheme = classicDarkTheme;
        break;
      case 'lightForestTheme':
        _selectedTheme = lightForestTheme;
        break;
      case 'sunnyBeachTheme':
        _selectedTheme = sunnyBeachTheme;
        break;
      case 'twillightTheme':
        _selectedTheme = twillightTheme;
        break;
      default:
        _selectedTheme = classicLightTheme;
        break;
    }
    notifyListeners();
  }

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}
