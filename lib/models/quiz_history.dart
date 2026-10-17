class QuizHistory {
  final String subjectTitle;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final DateTime date;

  QuizHistory({
    required this.subjectTitle,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.date,
  });
}

List<QuizHistory> globalQuizHistory = [];

// Status Autentikasi Global Sederhana
class UserAuth {
  static bool isLoggedIn = false;
  static String currentUsername = "Tamu";
  static String registeredEmail = "";
  static String registeredPassword = "";
}