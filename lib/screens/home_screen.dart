import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/quiz_history.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';

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
  void _checkAuthAndNavigate(BuildContext context, Widget destination) async {
    if (!UserAuth.isLoggedIn) {
      final loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            initialEmail: UserAuth.registeredEmail,
            onLoginSuccess: () {},
          ),
        ),
      );
      if (loggedIn == true) {
        setState(() {}); // Refresh tampilan beranda setelah login
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        // Menampilkan "Selamat Datang!" jika belum login, dan "Halo, [Nama]!" jika sudah login
        title: Text(
          UserAuth.isLoggedIn ? "Halo, ${UserAuth.currentUsername}! 👋" : "Selamat Datang! 👋",
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner "Find Your Courses"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, const Color(0xFF29B6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Find Your Courses",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Pilih mata kuliah Ilmu Komputer & selesaikan tantangan 10 soal (30s/soal).",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => widget.onSelectTab(1),
                      child: const Text("Lihat Semua Subject"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daftar Mata Kuliah Ilkom
              const Text("Pilih Mata Kuliah Ilkom", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...dummySubjects.map((sub) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sub.color.withOpacity(0.2),
                      child: Icon(sub.icon, color: sub.color),
                    ),
                    title: Text(sub.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("10 Soal • 30 detik / soal"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        _checkAuthAndNavigate(
                          context,
                          QuizScreen(
                            subject: sub,
                            userName: UserAuth.currentUsername,
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                          ),
                        );
                      },
                      child: const Text("Mulai", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}