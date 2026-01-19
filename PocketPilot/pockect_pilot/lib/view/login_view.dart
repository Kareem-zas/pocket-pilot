import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/signup_view.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/services/token_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  bool _obscurePassword = true;
  bool _loading = false;

  static const String baseUrl = 'http://localhost:8000/api';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _errorText(String? err) {
    if (err == null) return const SizedBox.shrink();
    return Container(
      width: 260,
      padding: const EdgeInsets.only(top: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        err,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    bool hasError = false;

    if (email.isEmpty) {
      emailError = "Email is required.";
      hasError = true;
    }

    if (password.isEmpty) {
      passwordError = "Password is required.";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (!response.headers['content-type']!
          .contains('application/json')) {
        throw Exception('Server did not return JSON');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      final token = data['token'];
      await TokenService.saveToken(token);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
  transitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (_, __, ___) => const HomePage(),
  transitionsBuilder: (_, animation, __, child) {
    return FadeTransition(opacity: animation, child: child);
  },
),

      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor2,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: GlobalColors.textColor3,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please sign in to your account',
                  style: TextStyle(
                    color: GlobalColors.buttonColor,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 90),

                AppTextField(
                  controller: emailController,
                  hint: "Email",
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() => emailError = null),
                ),
                _errorText(emailError),

                const SizedBox(height: 12),

                AppTextField(
                  controller: passwordController,
                  hint: "Password",
                  obscure: _obscurePassword,
                  onChanged: (_) => setState(() => passwordError = null),
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: GlobalColors.textColor,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                _errorText(passwordError),

                const SizedBox(height: 100),

                AppButton(
                  text: _loading ? "Signing In..." : "Sign In",
                  onPressed: () {
                    if (_loading) return;
                    _onLoginPressed();
                  },
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't Have An Account ? ",
                      style: TextStyle(
                        color: GlobalColors.textColor3,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpView(),
                          ),
                        );
                      },
                      child: Text(
                        " Sign Up",
                        style: TextStyle(
                          color: GlobalColors.buttonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
