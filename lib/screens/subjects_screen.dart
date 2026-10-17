import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/quiz_history.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';

class SubjectsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const SubjectsScreen({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  void _checkAuthAndNavigate(BuildContext context, Widget destination) async {
    if (!UserAuth.isLoggedIn) {
      final loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toggleTheme: toggleTheme,
            isDarkMode: isDarkMode,
            initialEmail: UserAuth.registeredEmail,
            onLoginSuccess: () {},
          ),
        ),
      );
      if (loggedIn == true) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subjects")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: dummySubjects.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
            itemBuilder: (context, index) {
              final sub = dummySubjects[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: sub.color.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(sub.icon, color: sub.color, size: 36),
                      ),
                      const SizedBox(height: 10),
                      Text(sub.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text("10 Soal", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () {
                            _checkAuthAndNavigate(
                              context,
                              QuizScreen(subject: sub, userName: UserAuth.currentUsername, toggleTheme: toggleTheme, isDarkMode: isDarkMode),
                            );
                          },
                          child: const Text("Enroll", style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}