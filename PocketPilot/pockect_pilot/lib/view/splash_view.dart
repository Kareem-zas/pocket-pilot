import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/token_service.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/view/login_view.dart';
import 'package:pockect_pilot/services/userprofile_service.dart';

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
    bool isTokenValid = false;

    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      () async {
        final token = await TokenService.getToken();
        if (token != null) {
          try {
            await UserService.getProfile();
            isTokenValid = true;
          } catch (e) {
            if (e.toString().toLowerCase().contains('token')) {
              await TokenService.clearToken();
            }
          }
        }
      }(),
    ]);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) =>
            isTokenValid ? const HomePage() : const LoginView(),
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