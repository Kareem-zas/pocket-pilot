import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/moneyInfo_view.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/services/auth_service.dart';
import 'package:pockect_pilot/services/token_service.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool loading = false;

  Future<void> _register() async {
    if (loading) return;

    setState(() {
      fullNameError = null;
      emailError = null;
      phoneError = null;
      passwordError = null;
      loading = true;
    });

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    bool hasError = false;

    if (fullName.isEmpty) {
      fullNameError = 'Full name is required';
      hasError = true;
    }

    if (email.isEmpty || !email.contains('@')) {
      emailError = 'Invalid email';
      hasError = true;
    }

    if (phone.isEmpty || phone.length < 9) {
      phoneError = 'Invalid phone number';
      hasError = true;
    }

    if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      hasError = true;
    } else if (password != confirm) {
      passwordError = 'Passwords do not match';
      hasError = true;
    }

    if (hasError) {
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      final response = await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );

      final token = response['token'];

      if (token != null && token is String) {
        await TokenService.saveToken(token);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MoneyInfoView()),
        );
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

  Widget _field({
    required Widget field,
    String? error,
  }) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          field,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 6),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor2,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'Create Account',
                  style: TextStyle(
                    color: GlobalColors.textColor3,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: TextStyle(
                    color: GlobalColors.textColor3.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 40),

                _field(
                  field: AppTextField(
                    controller: fullNameController,
                    hint: 'Full Name',
                  ),
                  error: fullNameError,
                ),
                const SizedBox(height: 14),

                _field(
                  field: AppTextField(
                    controller: emailController,
                    hint: 'Email',
                  ),
                  error: emailError,
                ),
                const SizedBox(height: 14),

                _field(
                  field: AppTextField(
                    controller: phoneController,
                    hint: 'Phone Number',
                  ),
                  error: phoneError,
                ),
                const SizedBox(height: 14),

                _field(
                  field: AppTextField(
                    controller: passwordController,
                    hint: 'Password',
                    obscure: obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _field(
                  field: AppTextField(
                    controller: confirmPasswordController,
                    hint: 'Confirm Password',
                    obscure: obscureConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ),
                  error: passwordError,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: 260,
                  child: AppButton(
                    text: loading ? 'Loading...' : 'Register',
                    onPressed: _register,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}