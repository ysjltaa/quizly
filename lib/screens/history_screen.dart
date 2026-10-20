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
        appBar: AppBar(title: const Text("Quiz History")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Authentication Required", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Please sign in to view your quiz performance and history logs.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode, initialEmail: UserAuth.registeredEmail)),
                      );
                      setState(() {});
                    },
                    child: const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz History")),
      body: SafeArea(
        child: globalQuizHistory.isEmpty
            ? const Center(child: Text("No quiz history recorded yet.", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: globalQuizHistory.length,
          itemBuilder: (context, index) {
            final item = globalQuizHistory[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15), child: Icon(Icons.assignment_turned_in, color: Theme.of(context).primaryColor)),
                title: Text(item.subjectTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Correct: ${item.correctCount}/${item.totalQuestions} • ${item.date.day}/${item.date.month}/${item.date.year}"),
                trailing: Text("Score: ${item.score}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ),
            );
          },
        ),
      ),
    );
  }
}
