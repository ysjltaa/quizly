import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/quiz_history.dart';
import '../widgets/custom_button.dart';

class ResultScreen extends StatelessWidget {
  final String subjectTitle;
  final List<Question> questions;
  final Map<int, int> selectedAnswers;
  final String userName;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ResultScreen({Key? key, required this.subjectTitle, required this.questions, required this.selectedAnswers, required this.userName, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctIndex) {
        correctCount++;
      }
    }

    final int score = (correctCount / questions.length * 100).toInt();

    globalQuizHistory.insert(
      0,
      QuizHistory(
        subjectTitle: subjectTitle,
        score: score,
        correctCount: correctCount,
        totalQuestions: questions.length,
        date: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Kuis"), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Subjek: $subjectTitle", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Benar: $correctCount dari ${questions.length} Soal"),
                        Text("Skor Akhir: $score", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text("Detail Evaluasi Soal:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final userChoice = selectedAnswers[index];
                    final bool isCorrect = userChoice == q.correctIndex;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${index + 1}. ${q.questionText}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              "Jawaban Anda: ${userChoice != null ? q.options[userChoice] : 'Tidak dijawab / Waktu Habis'}",
                              style: TextStyle(color: isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            if (!isCorrect) Text("Jawaban Benar: ${q.options[q.correctIndex]}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(text: "Kembali ke Beranda", onPressed: () => Navigator.pop(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
