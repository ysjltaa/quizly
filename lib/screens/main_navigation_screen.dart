import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'subjects_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final String? userName;

  const MainNavigationScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
    this.userName,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  static const double _wideBreakpoint = 800;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode, onSelectTab: (i) => setState(() => _currentIndex = i)),
      SubjectsScreen(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode),
      HistoryScreen(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode),
      ProfileScreen(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode),
    ];

    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: Row(
        children: [
          // Posisi anak Row dijaga tetap (pakai ternary) supaya state halaman tidak reset saat rotasi
          isWide
              ? NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: IconThemeData(color: primary),
            selectedLabelTextStyle: TextStyle(color: primary, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text("Home")),
              NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: Text("Subjects")),
              NavigationRailDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Text("History")),
              NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text("Profile")),
            ],
          )
              : const SizedBox.shrink(),
          isWide ? const VerticalDivider(width: 1) : const SizedBox.shrink(),
          Expanded(child: IndexedStack(index: _currentIndex, children: pages)),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: "Subjects"),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
