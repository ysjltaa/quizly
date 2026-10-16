import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/custom_button.dart';
import '../widgets/option_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String userName;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const QuizScreen({
    Key? key,
    required this.userName,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

// Menggunakan PageStorage / State Management sederhana agar aman saat rotasi layar
class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  Map<int, int> _selectedAnswers = {}; // Menyimpan pilihan jawaban per nomor soal (mencegah hilang saat rotasi)

  @override
  Widget build(BuildContext context) {
    final Question currentQuestion = dummyQuestions[_currentIndex];
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Soal ${_currentIndex + 1} dari ${dummyQuestions.length}"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Linear Progress Indicator Dinamis
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / dummyQuestions.length,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                  minHeight: 8,
                ),
                const SizedBox(height: 24),
                // Pertanyaan
                Text(
                  currentQuestion.questionText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // List Pilihan Jawaban menggunakan Reusable Widget (OptionCard)
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
                const Spacer(),
                // Tombol Navigasi Bawah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentIndex > 0)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentIndex--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Sebelumnya"),
                      )
                    else
                      const SizedBox.shrink(),
                    CustomButton(
                      text: _currentIndex == dummyQuestions.length - 1 ? "Selesai" : "Selanjutnya",
                      onPressed: _selectedAnswers.containsKey(_currentIndex)
                          ? () {
                        if (_currentIndex < dummyQuestions.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                        } else {
                          // Hitung Skor Akhir
                          int finalScore = 0;
                          _selectedAnswers.forEach((key, value) {
                            if (dummyQuestions[key].correctIndex == value) {
                              finalScore += 20; // Bobot per soal benar (100 / 5)
                            }
                          });

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultScreen(
                                userName: widget.userName,
                                score: finalScore,
                                totalQuestions: dummyQuestions.length,
                                toggleTheme: widget.toggleTheme,
                                isDarkMode: widget.isDarkMode,
                              ),
                            ),
                          );
                        }
                      }
                          : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pilih salah satu jawaban terlebih dahulu!"),
                            duration: Duration(seconds: 1500),
                          ),
                        );
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