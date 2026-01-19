import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/auth_service.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/moneyInfo_view.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  String? error;
  bool loading = false;

  Future<void> _register() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    if (password.text != confirm.text) {
      setState(() {
        error = 'Passwords do not match';
        loading = false;
      });
      return;
    }

    try {
      await AuthService.register(
        fullName: fullName.text,
        email: email.text,
        password: password.text,
        phone: phone.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MoneyInfoView()),
      );
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor2,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  color: GlobalColors.textColor3,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              AppTextField(controller: fullName, hint: 'Full Name'),
              const SizedBox(height: 12),
              AppTextField(controller: email, hint: 'Email'),
              const SizedBox(height: 12),
              AppTextField(controller: phone, hint: 'Phone'),
              const SizedBox(height: 12),
              AppTextField(controller: password, hint: 'Password', obscure: true),
              const SizedBox(height: 12),
              AppTextField(controller: confirm, hint: 'Confirm Password', obscure: true),

              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                  ),
                ),

              const SizedBox(height: 30),

              AppButton(
                text: loading ? 'Loading...' : 'Register',
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
