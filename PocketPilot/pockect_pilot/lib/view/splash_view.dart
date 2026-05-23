import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/token_service.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/view/login_view.dart';
import 'package:pockect_pilot/services/userprofile_service.dart';
import 'package:pockect_pilot/services/biometric_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _showBiometricFallback = false;
  bool _isTokenValid = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      () async {
        final token = await TokenService.getToken();
        if (token != null) {
          try {
            await UserService.getProfile();
            _isTokenValid = true;
          } catch (e) {
            if (e.toString().toLowerCase().contains('token')) {
              await TokenService.clearToken();
            }
          }
        }
      }(),
    ]);

    if (!mounted) return;

    if (_isTokenValid) {
      final bioEnabled = await BiometricService.isBiometricsEnabled();
      final bioCapable = await BiometricService.isDeviceCapable();

      if (bioEnabled && bioCapable) {
        _authenticateBiometrics();
        return;
      }
    }

    _navigateNext();
  }

  Future<void> _authenticateBiometrics() async {
    final authenticated = await BiometricService.authenticate();
    if (!mounted) return;

    if (authenticated) {
      _navigateHome();
    } else {
      setState(() {
        _showBiometricFallback = true;
      });
    }
  }

  void _navigateNext() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) =>
            _isTokenValid ? const HomePage() : const LoginView(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const HomePage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _fallbackToPassword() async {
    await TokenService.clearToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const LoginView(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor2,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/pocket-pilot-logo.png',
                  width: 230,
                  height: 230,
                ),
                if (_showBiometricFallback) ...[
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.fingerprint,
                    color: Colors.white70,
                    size: 60,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Pocket Locked",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please authenticate to unlock the dashboard",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_showBiometricFallback)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _authenticateBiometrics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Retry Biometrics",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _fallbackToPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: const Text(
                      "Log In with Password",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}