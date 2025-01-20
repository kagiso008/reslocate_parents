import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'package:reslocate/pages/splash_screen.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key}); // Add key parameter

  @override
  LogoScreenState createState() => LogoScreenState();
}

class LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Add const to Duration
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SvgPicture.asset(
          'assets/images/reslocate_logo_name.svg', // This is dynamic, so no const here
          width: 200,
        ),
      ),
    );
  }
}
