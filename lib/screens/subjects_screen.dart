import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/quiz_history.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const SubjectsScreen({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _searchQuery = '';

  void _checkAuthAndNavigate(BuildContext context, Widget destination) async {
    if (!UserAuth.isLoggedIn) {
      final loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            initialEmail: UserAuth.registeredEmail,
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
    final isDark = widget.isDarkMode;

    // Jumlah kolom mengikuti lebar layar (target ±200 per kartu), minimal 2 kolom
    final columns = (MediaQuery.sizeOf(context).width / 200).floor().clamp(2, 6).toInt();

    final searchResults = dummySubjects
        .where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Subjects"), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              // Search Input Field
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search subject...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 14),

              // Grid Catalog Subjek
              Expanded(
                child: searchResults.isEmpty
                    ? const Center(child: Text("No subject found matching query.", style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                  itemCount: searchResults.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 185,
                  ),
                  itemBuilder: (context, index) {
                    final sub = searchResults[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Bagian Atas: Badge Kategori & Ikon
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: sub.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      sub.category,
                                      style: TextStyle(color: sub.color, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: sub.color.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(sub.icon, color: sub.color, size: 22),
                                ),
                                const SizedBox(height: 6),
                                // Judul Mata Kuliah
                                Text(
                                  sub.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, height: 1.2),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "10 Questions",
                                  style: TextStyle(color: Colors.grey, fontSize: 9.5),
                                ),
                              ],
                            ),

                            // Bagian Bawah: Tombol Enroll
                            SizedBox(
                              width: double.infinity,
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _checkAuthAndNavigate(
                                  context,
                                  QuizScreen(
                                    subject: sub,
                                    userName: UserAuth.currentUsername,
                                    toggleTheme: widget.toggleTheme,
                                    isDarkMode: widget.isDarkMode,
                                  ),
                                ),
                                child: const Text("Enroll", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
