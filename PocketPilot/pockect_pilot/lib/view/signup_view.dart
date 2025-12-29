import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/moneyInfo_view.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart'; // new widgets

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearFieldError(String field) {
    setState(() {
      if (field == 'full') fullNameError = null;
      if (field == 'email') emailError = null;
      if (field == 'phone') phoneError = null;
      if (field == 'password') passwordError = null;
    });
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

  void _onRegisterPressed() {
    final full = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pwd = passwordController.text;
    final confirm = confirmPasswordController.text;

    setState(() {
      fullNameError = null;
      emailError = null;
      phoneError = null;
      passwordError = null;
    });

    bool hasError = false;

    if (full.isEmpty) {
      fullNameError = 'Full name is required.';
      hasError = true;
    }

    if (email.isEmpty) {
      emailError = 'Email is required.';
      hasError = true;
    }

    if (phone.isEmpty) {
      phoneError = 'Phone number is required.';
      hasError = true;
    }

    if (pwd.isEmpty || confirm.isEmpty) {
      passwordError = 'Please fill password and confirm password.';
      hasError = true;
    } else if (pwd != confirm) {
      passwordError = 'Passwords do not match.';
      hasError = true;
    }

    if (hasError) {
      setState(() {}); 
      return;
    }

    print("Full Name: $full");
    print("Email: $email");
    print("Phone: $phone");
    print("Password: $pwd");

    // Fade transition to MoneyInfoView
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => const MoneyInfoView(),
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
      backgroundColor: GlobalColors.mainColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    color: GlobalColors.textColor2,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Please fill the form to create an account',
                      style: TextStyle(
                        color: GlobalColors.textColor,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                AppTextField(
                  controller: fullNameController,
                  hint: "Full Name",
                  keyboardType: TextInputType.name,
                  onChanged: (_) => _clearFieldError('full'),
                ),

                _errorText(fullNameError),

                const SizedBox(height: 12),

                AppTextField(
                  controller: emailController,
                  hint: "Email",
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _clearFieldError('email'),
                ),

                _errorText(emailError),

                const SizedBox(height: 12),

                AppTextField(
                  controller: phoneController,
                  hint: "Phone Number",
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => _clearFieldError('phone'),
                ),

                _errorText(phoneError),

                const SizedBox(height: 12),

                AppTextField(
                  controller: passwordController,
                  hint: "Password",
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: GlobalColors.textColor2,
                    ),
                  ),
                  onChanged: (_) => _clearFieldError('password'),
                ),

                const SizedBox(height: 12),

                AppTextField(
                  controller: confirmPasswordController,
                  hint: "Confirm Password",
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: GlobalColors.textColor2,
                    ),
                  ),
                  onChanged: (_) => _clearFieldError('password'),
                ),

                _errorText(passwordError),

                const SizedBox(height: 40),

                AppButton(
                  text: "Register",
                  onPressed: _onRegisterPressed,
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account ? ",
                      style: TextStyle(
                        color: GlobalColors.textColor2,
                        fontSize: 9,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        " Sign In",
                        style: TextStyle(
                          color: GlobalColors.buttonColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
