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
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account"), elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Glow Ring Icon Header
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.12),
                      border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: Icon(Icons.person_add_alt_1_rounded, size: 56, color: primaryColor),
                  ),
                  const SizedBox(height: 20),
                  const Text("Join Quizly", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Create an account to track your quiz performance.", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 28),

                  _buildTextField(_usernameController, "Username", Icons.person_outline, isDark, primaryColor, (v) {
                    return v == null || v.isEmpty ? "Username is required" : null;
                  }),
                  const SizedBox(height: 16),

                  _buildTextField(_emailController, "Email Address", Icons.email_outlined, isDark, primaryColor, (v) {
                    return v == null || !v.contains('@') ? "Invalid email address" : null;
                  }),
                  const SizedBox(height: 16),

                  _buildTextField(_passController, "Password", Icons.lock_outline, isDark, primaryColor, (v) {
                    return v == null || v.length < 6 ? "Minimum 6 characters required" : null;
                  }, isObscure: true),
                  const SizedBox(height: 16),

                  _buildTextField(_confirmPassController, "Confirm Password", Icons.shield_outlined, isDark, primaryColor, (v) {
                    return v != _passController.text ? "Passwords do not match" : null;
                  }, isObscure: true),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Sign Up",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          UserAuth.currentUsername = _usernameController.text.trim();
                          UserAuth.registeredEmail = _emailController.text.trim();
                          UserAuth.registeredPassword = _passController.text.trim();

                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful! Please sign in.")));
                          Navigator.pop(context, UserAuth.registeredEmail);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Capsule Bar Navigasi Ke Sign In
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: primaryColor.withOpacity(0.15), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Already have an account?", style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13)),
                        const SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: primaryColor.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, Color primaryColor, String? Function(String?) validator, {bool isObscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
      validator: validator,
    );
  }
}
