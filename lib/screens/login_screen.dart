import 'package:flutter/material.dart';
import '../models/quiz_history.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final String initialEmail;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
    this.initialEmail = '',
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  final TextEditingController _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Akun"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 20),
                  const Text("Silakan Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "Masukkan email dan password Anda untuk masuk.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email wajib diisi";
                      // Opsional: Cek apakah email terdaftar (jika sudah ada akun yang dibuat)
                      if (UserAuth.registeredEmail.isNotEmpty && v.trim() != UserAuth.registeredEmail) {
                        return "Email belum terdaftar / tidak sesuai";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.vpn_key),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password wajib diisi";

                      // SINKRONISASI: Cek kecocokan password dengan yang di-register
                      if (UserAuth.registeredPassword.isNotEmpty && v.trim() != UserAuth.registeredPassword) {
                        return "Password salah!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Login",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          UserAuth.isLoggedIn = true;
                          UserAuth.registeredEmail = _emailController.text.trim();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Login Berhasil!")),
                          );

                          Navigator.pop(context, true); // Kembali ke halaman sebelumnya dengan status sukses
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final registeredEmail = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                      );
                      if (registeredEmail != null && registeredEmail is String) {
                        setState(() {
                          _emailController.text = registeredEmail;
                        });
                      }
                    },
                    child: const Text("Belum punya akun? Register di sini"),
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