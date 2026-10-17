import 'package:flutter/material.dart';
import '../models/quiz_history.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ProfileScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Pengguna")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: UserAuth.isLoggedIn
              ? Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  UserAuth.currentUsername.isNotEmpty ? UserAuth.currentUsername[0].toUpperCase() : "U",
                  style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                UserAuth.currentUsername,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(UserAuth.registeredEmail, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text("Ganti Mode Tema"),
                trailing: Switch(
                  value: widget.isDarkMode,
                  onChanged: (_) => widget.toggleTheme(),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    UserAuth.isLoggedIn = false;
                    UserAuth.currentUsername = "";
                  });
                },
              ),
            ],
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 90, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  "Anda Belum Login",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan login atau mendaftar akun untuk melihat info profil dan riwayat pengerjaan Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text("Login / Daftar Akun", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                            initialEmail: UserAuth.registeredEmail,
                            onLoginSuccess: () {},
                          ),
                        ),
                      );
                      setState(() {}); // Refresh halaman profil setelah login
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text("Ganti Mode Tema"),
                  trailing: Switch(
                    value: widget.isDarkMode,
                    onChanged: (_) => widget.toggleTheme(),
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