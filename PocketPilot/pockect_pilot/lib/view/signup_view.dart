import 'package:flutter/material.dart';

import 'package:pockect_pilot/view/money_info_view.dart';

import 'package:provider/provider.dart';

import 'signup_provider.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  Widget _input({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool obscure = false,
    bool toggle = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF1F2F6),
            prefixIcon: Icon(icon),
            suffixIcon: toggle
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpProvider(),
      child: Consumer<SignUpProvider>(
        builder: (context, p, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // HEADER
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.explore,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Pocket Pilot",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Create your account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Your personal financial cockpit starts here.",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 30),

                      // CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            _input(
                              label: "Name",
                              hint: "John Doe",
                              icon: Icons.person,
                              controller: p.fullName,
                              onChanged: (_) => p.validate(),
                            ),
                            const SizedBox(height: 12),

                            _input(
                              label: "Email",
                              hint: "pilot@example.com",
                              icon: Icons.email,
                              controller: p.email,
                              onChanged: (_) => p.validate(),
                            ),
                            const SizedBox(height: 12),

                            _input(
                              label: "Phone",
                              hint: "+1 (555)",
                              icon: Icons.phone,
                              controller: p.phone,
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 12),

                            _input(
                              label: "Password",
                              hint: "••••••",
                              icon: Icons.lock,
                              controller: p.password,
                              obscure: !p.showPassword,
                              toggle: true,
                              onToggle: p.togglePassword,
                              onChanged: (_) => p.validate(),
                            ),
                            const SizedBox(height: 12),

                            _input(
                              label: "Confirm",
                              hint: "••••••",
                              icon: Icons.verified_user,
                              controller: p.confirm,
                              obscure: !p.showConfirm,
                              toggle: true,
                              onToggle: p.toggleConfirm,
                              onChanged: (_) => p.validate(),
                            ),

                            if (p.error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  p.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: () async {
                                bool success = await p.register();
                                if (success && context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MoneyInfoView(),
                                    ),
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 55,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: p.loading
                                      ? Colors.blue.shade300
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    p.loading ? "Loading..." : "Sign Up →",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
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
          );
        },
      ),
    );
  }
}
