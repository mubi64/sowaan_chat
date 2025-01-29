import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sowaan_chat/models/employee.dart';
import 'package:sowaan_chat/responsive/responsive_flutter.dart';
import 'package:sowaan_chat/utils/image_path.dart';
import 'package:sowaan_chat/utils/shared_pref.dart';
import 'package:sowaan_chat/views/login_view.dart';

import 'home_page_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final SharedPref _prefs = SharedPref();
  Employee? userModel;

  @override
  void initState() {
    super.initState();
    _prefs
        .readObject(_prefs.prefKeyUserData)
        .then((value) => userDetails(value));
    startTime();
  }

  userDetails(value) async {
    if (value != null) {
      setState(() {
        userModel = Employee.fromJson(value);
      });
    }
  }

  startTime() async {
    var duration = Duration(seconds: 2);
    // var _duration = new Duration(milliseconds: 100);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) {
          return (userModel != null) ? HomePage() : LoginView();
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                ImagePath.icLogoTransparent,
                width: ResponsiveFlutter.of(context).scale(250),
                // height: ResponsiveFlutter.of(context).verticalScale(200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
