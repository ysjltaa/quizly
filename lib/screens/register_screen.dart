import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../models/quiz_history.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const RegisterScreen({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi Akun")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("Buat Akun Baru", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: "Username", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v == null || v.isEmpty ? "Username wajib diisi" : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v == null || !v.contains('@') ? "Email tidak valid" : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v == null || v.length < 6 ? "Password minimal 6 karakter" : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Verifikasi Password", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v != _passController.text ? "Password tidak sama" : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Daftar",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          UserAuth.currentUsername = _usernameController.text.trim();
                          UserAuth.registeredEmail = _emailController.text.trim();
                          UserAuth.registeredPassword = _passController.text.trim();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Registrasi Berhasil! Silakan masukkan password Anda.")),
                          );
                          // Otomatis kembali ke Login dengan email terisi
                          Navigator.pop(context, UserAuth.registeredEmail);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}