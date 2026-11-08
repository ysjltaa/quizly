import 'package:flutter/material.dart';

class QuizlyPalette {
  final String name;
  final Color seed;
  final List<Color> gradient;
  final IconData icon;
  const QuizlyPalette(this.name, this.seed, this.gradient, this.icon);
}

const palettes = <QuizlyPalette>[
  QuizlyPalette('Ocean', Color(0xFF1565C0),
      [Color(0xFF1E88E5), Color(0xFF0D47A1)], Icons.water_drop_rounded),
  QuizlyPalette('Campfire', Color(0xFFE64A19),
      [Color(0xFFFF8A50), Color(0xFFB71C1C)], Icons.local_fire_department_rounded),
  QuizlyPalette('Mars Escape', Color(0xFF7B1FA2),
      [Color(0xFF8E24AA), Color(0xFF311B92)], Icons.rocket_launch_rounded),
  QuizlyPalette('Forest', Color(0xFF2E7D32),
      [Color(0xFF43A047), Color(0xFF1B5E20)], Icons.park_rounded),
  QuizlyPalette('Sneaky Cat', Color(0xFFEF6C00),
      [Color(0xFFFFA726), Color(0xFFE65100)], Icons.pets_rounded),
];

class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  int paletteIndex = 0;
  QuizlyPalette get palette => palettes[paletteIndex];

  void setPalette(int i) {
    paletteIndex = i;
    notifyListeners();
  }
}