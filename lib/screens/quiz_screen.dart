import 'dart:async';
import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/question.dart';
import '../widgets/custom_button.dart';
import '../widgets/option_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;
  final String userName;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const QuizScreen({
    Key? key,
    required this.subject,
    required this.userName,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;

  // State Management: Menyimpan progres jawaban pengguna agar tidak hilang saat rotasi/pindah halaman
  final Map<int, int> _selectedAnswers = {};

  Timer? _timer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_secondsLeft > 0) {
          setState(() {
            _secondsLeft--;
          });
        } else {
          _nextQuestion();
        }
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.subject.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          subjectTitle: widget.subject.title,
          questions: widget.subject.questions,
          selectedAnswers: _selectedAnswers,
          userName: widget.userName,
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Quiz?"),
        content: const Text("Your current quiz attempt will be ended and submitted with existing answers."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              _finishQuiz(); // Menyerahkan progres jawaban yang sudah terisi saat ini
            },
            child: const Text("Submit & Exit", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final Question currentQuestion = widget.subject.questions[_currentIndex];
    final isDark = widget.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.subject.title} (${_currentIndex + 1}/10)"),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Visual Dynamic Timer & Soal Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Question ${_currentIndex + 1} of 10",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text("Select one answer and proceed", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: _secondsLeft / 30,
                            strokeWidth: 5,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _secondsLeft <= 5 ? Colors.redAccent : primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          "$_secondsLeft",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _secondsLeft <= 5 ? Colors.redAccent : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Floating Card Soal
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "SOAL NO. ${_currentIndex + 1}",
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentQuestion.questionText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pilihan Jawaban (Hanya Maju, Tidak Bisa Kembali)
                ...List.generate(currentQuestion.options.length, (index) {
                  return OptionCard(
                    optionText: currentQuestion.options[index],
                    isSelected: _selectedAnswers[_currentIndex] == index,
                    onTap: () {
                      setState(() {
                        _selectedAnswers[_currentIndex] = index;
                      });
                    },
                  );
                }),
                const SizedBox(height: 28),

                // Tombol aksi tunggal (Tanpa Tombol Previous)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _currentIndex == widget.subject.questions.length - 1 ? "Finish Quiz" : "Next Question",
                    onPressed: () {
                      _nextQuestion();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
