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

  const QuizScreen({Key? key, required this.subject, required this.userName, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
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
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _nextQuestion();
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
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda ingin keluar? Jawaban yang telah diisi akan terhapus dan kuis diulang dari awal."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Keluar", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final Question currentQuestion = widget.subject.questions[_currentIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.subject.title} (${_currentIndex + 1}/10)"),
          actions: [
            IconButton(icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: widget.toggleTheme),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Progres: ${_currentIndex + 1}/10", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      avatar: const Icon(Icons.timer, size: 18, color: Colors.white),
                      label: Text("$_secondsLeft detik", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: _secondsLeft <= 5 ? Colors.red : Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.subject.questions.length,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  minHeight: 6,
                ),
                const SizedBox(height: 20),
                Text(currentQuestion.questionText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
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
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentIndex > 0)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentIndex--;
                          });
                          _startTimer();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Sebelumnya"),
                      )
                    else
                      const SizedBox.shrink(),
                    CustomButton(
                      text: _currentIndex == widget.subject.questions.length - 1 ? "Selesai" : "Selanjutnya",
                      onPressed: () {
                        _nextQuestion();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
