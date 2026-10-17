import 'package:flutter/material.dart';
import '../models/quiz_history.dart';
import 'login_screen.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HistoryScreen({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    if (!UserAuth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("Riwayat Pengerjaan")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person, size: 70, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Anda belum login!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Silakan login terlebih dahulu untuk melihat riwayat pengerjaan kuis Anda.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
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
                    setState(() {});
                  },
                  child: const Text("Login Sekarang"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pengerjaan")),
      body: SafeArea(
        child: globalQuizHistory.isEmpty
            ? const Center(child: Text("Belum ada riwayat kuis yang diselesaikan.", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: globalQuizHistory.length,
          itemBuilder: (context, index) {
            final item = globalQuizHistory[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2), child: Icon(Icons.assignment_turned_in, color: Theme.of(context).primaryColor)),
                title: Text(item.subjectTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Benar ${item.correctCount}/${item.totalQuestions} • ${item.date.day}/${item.date.month}/${item.date.year}"),
                trailing: Text("Skor: ${item.score}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ),
            );
          },
        ),
      ),
    );
  }
}