import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockect_pilot/view/signup_view.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/view/forgot_password_page.dart';
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

  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  Timer? _lockoutTimer;
  int _remainingSeconds = 0;

  static const String baseUrl = 'http://192.168.0.109:8000/api';

  @override
  void initState() {
    super.initState();
    _checkLockout();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLockout() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTimeStr = prefs.getString('lockout_until');
    if (lockoutTimeStr != null) {
      final lockoutTime = DateTime.parse(lockoutTimeStr);
      if (lockoutTime.isAfter(DateTime.now())) {
        setState(() {
          _lockoutUntil = lockoutTime;
          _failedAttempts = 5;
        });
        _startLockoutTimer();
      } else {
        await prefs.remove('lockout_until');
      }
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    if (_lockoutUntil == null) return;

    final difference = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    if (difference <= 0) {
      _endLockout();
      return;
    }

    setState(() {
      _remainingSeconds = difference;
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        timer.cancel();
        _endLockout();
      } else {
        setState(() {
          _remainingSeconds = diff;
        });
      }
    });
  }

  Future<void> _endLockout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lockout_until');
    setState(() {
      _lockoutUntil = null;
      _failedAttempts = 0;
      _remainingSeconds = 0;
    });
  }

  Future<void> _registerFailedAttempt() async {
    setState(() {
      _failedAttempts++;
    });

    if (_failedAttempts >= 5) {
      final lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lockout_until', lockoutUntil.toIso8601String());

      setState(() {
        _lockoutUntil = lockoutUntil;
      });
      _startLockoutTimer();
    }
  }

  Widget _errorText(String? err) {
    if (err == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        err,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    if (_lockoutUntil != null && _lockoutUntil!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Too many failed attempts. Try again in $_remainingSeconds seconds."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
        headers: {'Content-Type': 'application/json'},
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

      // Reset lockout and failed attempts on success
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lockout_until');

      final token = data['token'];
      await TokenService.saveToken(token);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, _, _) => const HomePage(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      await _registerFailedAttempt();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _socialButton(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: isDark ? Colors.white70 : Colors.black87),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ICON
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.flight,
                      color: Colors.white, size: 40),
                ),

                const SizedBox(height: 20),

                Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Welcome back, Captain. Check your flight path.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                ),

                const SizedBox(height: 30),

                // CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "EMAIL ADDRESS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: emailController,
                        onChanged: (_) =>
                            setState(() => emailError = null),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: "name@company.com",
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F2F6),
                          prefixIcon:
                              Icon(Icons.email_outlined, color: isDark ? Colors.white70 : Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      _errorText(emailError),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PASSWORD",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                           GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) =>
                            setState(() => passwordError = null),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F2F6),
                          prefixIcon:
                              Icon(Icons.lock_outline, color: isDark ? Colors.white70 : Colors.black54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      _errorText(passwordError),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              (_loading || _lockoutUntil != null) ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D9E75),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _lockoutUntil != null
                                ? "Locked out (${_remainingSeconds}s)"
                                : (_loading ? "Signing In..." : "Log In"),
                            style: TextStyle(
                              color: _lockoutUntil != null
                                  ? (isDark ? Colors.white38 : Colors.black38)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "OR CONTINUE WITH",
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child:
                          _socialButton("Google", Icons.g_mobiledata),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _socialButton("Apple", Icons.apple),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account? ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpView(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.blue,
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
