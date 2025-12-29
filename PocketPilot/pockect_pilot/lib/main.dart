import 'package:flutter/material.dart';
import 'package:pockect_pilot/view/splash_view.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'SF',),
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}