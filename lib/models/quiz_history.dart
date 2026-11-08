class QuizHistory {
  final String subjectTitle;
  final int score; // persentase akurasi (0-100)
  final int correctCount;
  final int totalQuestions;
  final DateTime date;

  // Khusus Race Mode (opsional, kuis biasa tidak perlu mengisi)
  final bool isRace;
  final String? rivalName;
  final String? raceResult; // Win / Lose / Draw / Forfeit
  final int? raceScore; // poin race (kecepatan + ketepatan)

  QuizHistory({
    required this.subjectTitle,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.date,
    this.isRace = false,
    this.rivalName,
    this.raceResult,
    this.raceScore,
  });
}

List<QuizHistory> globalQuizHistory = [];

class UserAuth {
  static bool isLoggedIn = false;
  static String currentUsername = "";
  static String registeredEmail = "";
  static String registeredPassword = "";
}
