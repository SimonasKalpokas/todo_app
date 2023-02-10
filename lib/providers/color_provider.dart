import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/app_colors.dart';

const colorThemes = {
  "dark": AppColors(
      primaryColor: Color(0xFFFFDD33),
      primaryColorLight: Color(0xFFFFEC8D),
      secondaryColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFE3E3E3),
      backgroundColor: Color(0xFF282828),
      headerFooterColor: Color(0xFF484848),
      taskBackgroundColor: Color(0xFF383838),
      buttonTextColor: Color(0xFF252525),
      red: Color(0xFFFF6D6D)),
  "light": AppColors(
    primaryColor: Color(0xFF000000),
    primaryColorLight: Color(0xFF444444),
    secondaryColor: Color(0xFF000000),
    borderColor: Color(0xFFFFD699),
    backgroundColor: Color(0xFFFFF9F1),
    headerFooterColor: Color(0xFFFFD699),
    taskBackgroundColor: Color(0xFFFFFFFF),
    buttonTextColor: Color(0xFF000000),
    red: Color(0xFFFF0000),
  ),
};

class ColorProvider with ChangeNotifier {
  late String _theme;
  late AppColors _appColors;
  final SharedPreferences _prefs;

  String get theme => _theme;
  AppColors get appColors => _appColors;

  ColorProvider(SharedPreferences prefs) : _prefs = prefs {
    _theme = _prefs.getString("theme") ?? "light";
    if (!colorThemes.containsKey(_theme)) {
      _theme = "light";
    }
    _appColors = colorThemes[_theme]!;
  }

  Future<void> setAppColors(String theme) async {
    _theme = theme;
    if (!colorThemes.containsKey(_theme)) {
      _theme = "light";
    }
    await _prefs.setString("theme", _theme);
    _appColors = colorThemes[_theme]!;
    notifyListeners();
  }
}
