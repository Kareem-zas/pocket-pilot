import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/login_view.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
     Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, animation, __) => const LoginView(),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);
    });
    return Scaffold(
      backgroundColor: GlobalColors.mainColor ,
      body: Center(
        child: Image.asset('assets/images/app_logo.png',
        width: 235,
        height: 235,),
      ),
    );
  }
}