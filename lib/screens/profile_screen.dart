import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/quiz_history.dart';
import '../theme/theme_controller.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'race_lobby_screen.dart';
import 'theme_picker_sheet.dart';

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _profileImage = File(image.path));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated!")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  void _removePhoto() {
    setState(() => _profileImage = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile photo removed")),
    );
  }

  // Belum punya foto -> langsung tambah. Sudah punya -> pilih edit / remove.
  void _onPhotoTap() {
    if (_profileImage == null) {
      _pickImage();
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit photo"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text("Remove photo", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _removePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDeco(bool isDark) => BoxDecoration(
    color: isDark ? const Color(0xFF1E293B) : Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );

  Widget _iconBox(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: color),
  );

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ),
  );

  Widget _themeCard() {
    final p = ThemeController.instance.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => showThemePicker(context),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(colors: p.gradient),
          ),
          child: Row(
            children: [
              Icon(p.icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Theme: ${p.name}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.edit, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appearanceCard(bool isDark) {
    return Container(
      decoration: _cardDeco(isDark),
      child: Column(
        children: [
          ListTile(
            leading: _iconBox(Icons.brightness_6, Colors.orange),
            title: const Text("Dark Theme Mode", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: Switch(value: widget.isDarkMode, onChanged: (_) => widget.toggleTheme()),
          ),
          _themeCard(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = widget.isDarkMode;
    final hasPhoto = _profileImage != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: UserAuth.isLoggedIn
              ? Column(
            children: [
              const SizedBox(height: 10),
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
                      backgroundImage: hasPhoto ? FileImage(_profileImage!) : null,
                      child: !hasPhoto
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
                      onTap: _onPhotoTap,
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
                        child: Icon(hasPhoto ? Icons.edit : Icons.add_a_photo, color: Colors.white, size: 18),
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

              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: _cardDeco(isDark),
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
              const SizedBox(height: 20),

              // Race Mode banner
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RaceLobbyScreen(myName: UserAuth.currentUsername),
                    ),
                  );
                  if (mounted) setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: ThemeController.instance.palette.gradient),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.flag_circle_rounded, color: Colors.white, size: 40),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Race Mode",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text("Challenge a friend: fastest and most accurate wins",
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _sectionTitle("Appearance"),
              _appearanceCard(isDark),
              const SizedBox(height: 28),

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
                      Text("Sign Out",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Quizly v1.0.0", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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
                Text("Sign in to sync your profile, photo, and quiz records.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Sign In / Register",
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                            initialEmail: UserAuth.registeredEmail,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 28),
                _appearanceCard(isDark),
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
