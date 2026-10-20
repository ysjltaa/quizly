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

  const ResultScreen({
    Key? key,
    required this.subjectTitle,
    required this.questions,
    required this.selectedAnswers,
    required this.userName,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctIndex) {
        correctCount++;
      }
    }

    final int score = (correctCount / questions.length * 100).toInt();
    final isDark = isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    // Catat ke riwayat
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

    String badgeTitle = "Good Attempt!";
    Color badgeColor = Colors.orange;
    if (score >= 80) {
      badgeTitle = "Mastery Level!";
      badgeColor = Colors.green;
    } else if (score < 50) {
      badgeTitle = "Keep Learning!";
      badgeColor = Colors.redAccent;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Performance"), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              // Score Radial Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    // Meter Radial Skor
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                          ),
                        ),
                        Text(
                          "$score%",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeTitle,
                              style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(subjectTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text("Correct: $correctCount / ${questions.length} Questions", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text("Detailed Answer Key:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(height: 10),

              // Review List
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final userChoice = selectedAnswers[index];
                    final bool isCorrect = userChoice == q.correctIndex;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${index + 1}. ${q.questionText}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Your Answer: ${userChoice != null ? q.options[userChoice] : 'Not answered / Timeout'}",
                                  style: TextStyle(
                                    color: isCorrect ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isCorrect)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 22.0),
                              child: Text("Correct Answer: ${q.options[q.correctIndex]}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(text: "Back to Home Navigation", onPressed: () => Navigator.pop(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
