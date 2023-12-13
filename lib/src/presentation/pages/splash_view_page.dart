import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:scanner3d/main.dart';
import 'package:scanner3d/src/presentation/pages/current_scan_page.dart';
import 'package:scanner3d/src/presentation/pages/scan_list_page.dart';

class SplashViewPage extends StatefulWidget {
  const SplashViewPage({super.key});

  @override
  State<SplashViewPage> createState() => _SplashViewPageState();
}

class _SplashViewPageState extends State<SplashViewPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()
            //CurrentScanPage(),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/animation_splash.json',
          width: double.infinity,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
