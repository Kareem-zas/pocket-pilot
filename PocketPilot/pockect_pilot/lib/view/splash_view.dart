import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/token_service.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/view/login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final token = await TokenService.getToken();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) =>
            token != null ? const HomePage() : const LoginView(),
        transitionsBuilder: (_, animation, _, child) {
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
      body: Center(
        child: Image.asset(
          'assets/images/pocket-pilot-logo.png',
          width: 235,
          height: 235,
        ),
      ),
    );
  }
}