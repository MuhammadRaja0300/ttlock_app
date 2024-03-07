import 'dart:async';

import 'package:ddbox/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimerFun();
  }
  @override
  Widget build(BuildContext context) {
    return splash();
  }
  startTimerFun() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, timerCallback);
  }

  timerCallback() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

Widget splash() {
  return Scaffold(
    body: Center(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xfff1faf7),
            ),
          ),
          Center(
            child: SvgPicture.asset("images/locksplash.svg"),
          )
        ],
      ),
    ),
  );
}