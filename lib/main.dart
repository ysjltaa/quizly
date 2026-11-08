import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatefulWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  bool _isDarkMode = false;
  bool _showSplash = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Timpa warna utama AppTheme dengan palet yang dipilih user
  ThemeData _tint(ThemeData base) {
    final seed = ThemeController.instance.palette.seed;
    return base.copyWith(
      primaryColor: seed,
      colorScheme: base.colorScheme.copyWith(primary: seed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) => MaterialApp(
        title: 'Quizly',
        debugShowCheckedModeBanner: false,
        theme: _tint(AppTheme.lightTheme),
        darkTheme: _tint(AppTheme.darkTheme),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _showSplash
              ? SplashScreen(
            key: const ValueKey('splash'),
            onFinish: () => setState(() => _showSplash = false),
          )
              : KeyedSubtree(
            key: const ValueKey('main'),
            child: MainNavigationScreen(
              toggleTheme: _toggleTheme,
              isDarkMode: _isDarkMode,
            ),
          ),
        ),
      ),
    );
  }
}
