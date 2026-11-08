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
  Color _resultColor(String? r) {
    switch (r) {
      case 'Win':
        return Colors.green;
      case 'Draw':
        return Colors.orange;
      default:
        return Colors.redAccent; // Lose / Forfeit
    }
  }

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

    // Terbaru di atas
    final items = [...globalQuizHistory]..sort((a, b) => b.date.compareTo(a.date));
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz History")),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(child: Text("No quiz history recorded yet.", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final dateStr = "${item.date.day}/${item.date.month}/${item.date.year}";

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: primary.withOpacity(0.15),
                  child: Icon(item.isRace ? Icons.flag_rounded : Icons.assignment_turned_in, color: primary),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(item.subjectTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (item.isRace) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text("RACE",
                            style: TextStyle(color: primary, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                subtitle: item.isRace
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text("vs ${item.rivalName ?? '-'} • $dateStr"),
                    Text("Correct: ${item.correctCount}/${item.totalQuestions}"),
                  ],
                )
                    : Text("Correct: ${item.correctCount}/${item.totalQuestions} • $dateStr"),
                trailing: item.isRace
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item.raceResult ?? '-',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _resultColor(item.raceResult))),
                    Text("${item.raceScore ?? 0} pts",
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
                    : Text("Score: ${item.score}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
              ),
            );
          },
        ),
      ),
    );
  }
}
