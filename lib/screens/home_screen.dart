import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/quiz_history.dart';
import '../theme/theme_controller.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';
import 'race_lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Function(int) onSelectTab;

  const HomeScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.onSelectTab,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  void _checkAuthAndNavigate(BuildContext context, Widget destination) async {
    if (!UserAuth.isLoggedIn) {
      final loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            initialEmail: UserAuth.registeredEmail,
          ),
        ),
      );
      if (loggedIn == true) {
        setState(() {});
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
    }
  }

  Future<void> _openRace() async {
    if (!UserAuth.isLoggedIn) {
      final ok = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            initialEmail: UserAuth.registeredEmail,
          ),
        ),
      );
      if (ok != true || !mounted) return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RaceLobbyScreen(myName: UserAuth.currentUsername)),
    );
    if (mounted) setState(() {}); // refresh statistik setelah race
  }

  Widget _buildActivityTile(QuizHistory item, bool isDark, Color primaryColor) {
    final subtitle = item.isRace
        ? "vs ${item.rivalName ?? '-'} • ${item.raceResult ?? '-'} • ${item.correctCount}/${item.totalQuestions} correct"
        : "${item.correctCount}/${item.totalQuestions} correct • Score ${item.score}%";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.15),
          child: Icon(item.isRace ? Icons.flag_rounded : Icons.assignment_turned_in,
              color: primaryColor, size: 20),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(item.subjectTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            if (item.isRace) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("RACE",
                    style: TextStyle(color: primaryColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _buildSubjectTile(Subject sub, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: sub.color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: sub.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(sub.icon, color: sub.color, size: 28),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sub.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.25),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: sub.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                sub.category,
                style: TextStyle(color: sub.color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Text(
            "10 Questions • 30s Per Question",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _checkAuthAndNavigate(
            context,
            QuizScreen(
              subject: sub,
              userName: UserAuth.currentUsername,
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
            ),
          ),
          child: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = widget.isDarkMode;

    double avgScore = 0;
    if (globalQuizHistory.isNotEmpty) {
      final total = globalQuizHistory.fold<int>(0, (sum, item) => sum + item.score);
      avgScore = total / globalQuizHistory.length;
    }

    final recent = ([...globalQuizHistory]..sort((a, b) => b.date.compareTo(a.date)))
        .take(3)
        .toList();

    final filteredSubjects = _selectedCategory == 'All'
        ? dummySubjects
        : dummySubjects.where((s) => s.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UserAuth.isLoggedIn ? "Hello, ${UserAuth.currentUsername}! 👋" : "Welcome, Student! 👋",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: ThemeController.instance.palette.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeController.instance.palette.gradient.last.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Elevate Computer Science Knowledge",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Test your skills across 10 specialized CS subjects with 30s timer per question.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => widget.onSelectTab(1),
                      icon: const Icon(Icons.explore, size: 18),
                      label: const Text("Explore All Subjects", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatWidget("Quizzes Done", "${globalQuizHistory.length}", Icons.assignment_turned_in, Colors.orange),
                    Container(height: 35, width: 1, color: Colors.grey.withOpacity(0.2)),
                    _buildStatWidget("Avg Score", "${avgScore.toInt()}%", Icons.analytics, Colors.green),
                    Container(height: 35, width: 1, color: Colors.grey.withOpacity(0.2)),
                    _buildStatWidget("Streak", "3 Days", Icons.local_fire_department, Colors.redAccent),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Race Mode card
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _openRace,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: primaryColor.withOpacity(0.4)),
                    color: primaryColor.withOpacity(0.08),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag_circle_rounded, color: primaryColor, size: 38),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Race Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 2),
                            Text("Challenge a friend: fastest and most accurate wins",
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: primaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity
              if (UserAuth.isLoggedIn && recent.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Activity", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => widget.onSelectTab(2), child: const Text("See all")),
                  ],
                ),
                const SizedBox(height: 6),
                ...recent.map((item) => _buildActivityTile(item, isDark, primaryColor)),
                const SizedBox(height: 14),
              ],

              // 3. Filter Category Chips
              const Text("Explore Categories", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Fundamental', 'Core', 'Advanced'].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        selectedColor: primaryColor.withOpacity(0.2),
                        checkmarkColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3)),
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Subjects List (1 - 3 kolom mengikuti lebar layar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subjects List", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text("${filteredSubjects.length} Available", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = (constraints.maxWidth / 280).floor().clamp(1, 3).toInt();
                  const gap = 12.0;
                  final itemWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    children: filteredSubjects
                        .map((sub) => SizedBox(
                      width: itemWidth,
                      child: _buildSubjectTile(sub, isDark, primaryColor),
                    ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatWidget(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
