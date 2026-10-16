import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'welcome_screen.dart';

class ResultScreen extends StatelessWidget {
  final String userName;
  final int score;
  final int totalQuestions;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ResultScreen({
    Key? key,
    required this.userName,
    required this.score,
    required this.totalQuestions,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Kuis"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 500 : screenWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                const SizedBox(height: 20),
                Text(
                  "Kerja Bagus, $userName!",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text("Skor Akhir Anda:", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                Text(
                  "$score",
                  style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: "Ulangi Kuis",
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomeScreen(
                          toggleTheme: toggleTheme,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}