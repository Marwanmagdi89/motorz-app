import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/Colors.dart';
import '../helpers/Constant.dart';
import '../helpers/Icons.dart';
import '../main.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = Duration(seconds: 3);
    return Timer(duration, () async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (showOnboardingScreen && (pref.getBool('isFirstTimeUser') ?? true)) {
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      } else {
        navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
            builder: (_) => MyHomePage(
                  webUrl: webinitialUrl,
                )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark));
    return Scaffold(
      body: Container(
          padding: EdgeInsets.zero,
          height: double.infinity,
          width: MediaQuery.of(context).size.width,
          color: splashBackColor,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2000),
              child: Image.asset(
                iconPath + 'splash_icon.png',
                width: 200,
                height: 200,
              ),
            ),
          )),
    );
  }
}
