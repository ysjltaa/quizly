import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/quiz_history.dart';
import '../widgets/custom_button.dart'; // <--- IMPORT INI YANG KURANG
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ProfileScreen({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: UserAuth.isLoggedIn
              ? Column(
            children: [
              const SizedBox(height: 10),
              // Avatar Profile dengan Halo Ring
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withOpacity(0.4), width: 2),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withOpacity(0.25), blurRadius: 18, spreadRadius: 2),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: primaryColor,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Text(
                        UserAuth.currentUsername.isNotEmpty ? UserAuth.currentUsername[0].toUpperCase() : "U",
                        style: const TextStyle(fontSize: 42, color: Colors.white, fontWeight: FontWeight.bold),
                      )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(UserAuth.currentUsername, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(UserAuth.registeredEmail, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 24),

              // Ringkasan Statistik
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Quizzes", "${globalQuizHistory.length}"),
                    Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2)),
                    _buildStatItem("Status", "Active"),
                    Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2)),
                    _buildStatItem("Role", "Student"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Pengaturan
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.photo_library_outlined, color: Colors.blue),
                      ),
                      title: const Text("Change Photo from Gallery", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: _pickImageFromGallery,
                    ),
                    Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.brightness_6, color: Colors.orange),
                      ),
                      title: const Text("Dark Theme Mode", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: Switch(value: widget.isDarkMode, onChanged: (_) => widget.toggleTheme()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Sign Out Pill/Capsule Button
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  setState(() {
                    UserAuth.isLoggedIn = false;
                    UserAuth.currentUsername = "";
                    _profileImage = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.logout, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.12),
                    border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(Icons.account_circle_outlined, size: 70, color: primaryColor),
                ),
                const SizedBox(height: 20),
                const Text("Guest Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Sign in to sync your profile, photo, and quiz records.", textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Sign In / Register",
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode, initialEmail: UserAuth.registeredEmail)),
                      );
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Divider(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text("Dark Theme Mode"),
                  trailing: Switch(value: widget.isDarkMode, onChanged: (_) => widget.toggleTheme()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
