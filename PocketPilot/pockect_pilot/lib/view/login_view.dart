import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/signup_view.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';

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

  void _clearError(String field) {
    setState(() {
      if (field == "email") emailError = null;
      if (field == "password") passwordError = null;
    });
  }

  void _onLoginPressed() {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

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

Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        HomePage(currentBalance: 0),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);
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
                  onChanged: (_) => _clearError("email"),
                ),
                _errorText(emailError),
                const SizedBox(height: 12),
AppTextField(
  controller: passwordController,
  hint: "Password",
  obscure: _obscurePassword,
  onChanged: (_) => _clearError("password"),
  suffix: IconButton(
    icon: Icon(
      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                  text: "Sign In",
                  onPressed: _onLoginPressed,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't Have An Account ? ",
                      style: TextStyle(
                        color: GlobalColors.textColor3,
                        fontSize: 9,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpView(),
                          ),
                        );
                      },
                      child: Text(
                        " Sign Up",
                        style: TextStyle(
                          color: GlobalColors.buttonColor,
                          fontSize: 9,
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