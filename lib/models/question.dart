class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });
}

// Data Dummy Kuis Pemrograman Mobile & Umum
final List<Question> dummyQuestions = [
  Question(
    questionText: "Widget apa yang digunakan di Flutter untuk tampilan yang tidak berubah (immutable)?",
    options: ["StatefulWidget", "StatelessWidget", "ChangeNotifier", "InheritedWidget"],
    correctIndex: 1,
  ),
  Question(
    questionText: "Bahasa pemrograman apa yang digunakan untuk pengembangan aplikasi Flutter?",
    options: ["Java", "Kotlin", "Dart", "Swift"],
    correctIndex: 2,
  ),
  Question(
    questionText: "Fungsi utama dari Git / GitHub dalam pengembangan aplikasi adalah...",
    options: [
      "Menjalankan emulator Android",
      "Melacak kemajuan proyek & version control",
      "Mengkompilasi kode APK",
      "Mendesain UI secara otomatis"
    ],
    correctIndex: 1,
  ),
  Question(
    questionText: "Komponen yang digunakan untuk menata letak widget secara berurutan secara vertikal adalah...",
    options: ["Row", "Column", "Stack", "Container"],
    correctIndex: 1,
  ),
  Question(
    questionText: "Manakah yang merupakan keunggulan dari Flutter?",
    options: [
      "Multiplatform (Android & iOS)",
      "Hot Reload",
      "Performa mendekati native",
      "Semua jawaban benar"
    ],
    correctIndex: 3,
  ),
];