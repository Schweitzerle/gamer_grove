import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auth_service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:gamer_grove/main.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';

import '../landingScreen/bottom_nav_bar.dart';
import '../loginRegistration/login/bloc/login_bloc.dart';
import '../loginRegistration/login_registration_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 400), () {
      setState(() {
        _a = true;
      });
    });
    Timer(Duration(milliseconds: 400), () {
      setState(() {
        _b = true;
      });
    });
    Timer(Duration(milliseconds: 1300), () {
      setState(() {
        _c = true;
      });
    });
    Timer(Duration(milliseconds: 1700), () {
      setState(() {
        _e = true;
      });
    });
    Timer(Duration(milliseconds: 3400), () {
      setState(() {
        _d = true;
      });
    });
    Timer(Duration(milliseconds: 3850), () {
      setState(() {

        Navigator.of(context).pushReplacement(
          ThisIsFadeRoute(
            route: getInitialScreen(),
          ),
        );
      });
    });
  }

  Widget getInitialScreen() {
    return FutureBuilder(
      // Note: Remove the Future and use FirebaseAuth.instance.currentUser
      future: FirebaseAuthService(authService: FirebaseAuth.instance)
          .getCurrentUser(),
      builder: (context, AsyncSnapshot<UserEntity?> snapshot) {
        // Check if FirebaseAuth.instance.currentUser is not null
        if (FirebaseAuth.instance.currentUser != null) {
          return LiquidTabBar();
        } else {
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider<FirebaseAuthService>(
                create: (context) => FirebaseAuthService(
                  authService: FirebaseAuth.instance,
                ),
              ),
              RepositoryProvider<LoginBloc>(
                create: (context) => LoginBloc(
                  authService: context.read<FirebaseAuthService>(),
                ),
              ),
            ],
            child: LoginRegistrationPage(),
          );
        }
      },
    );
  }
  bool _a = false;
  bool _b = false;
  bool _c = false;
  bool _d = false;
  bool _e = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _h = MediaQuery.of(context).size.height;
    double _w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:  Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: _d ? 900 : 2500),
              curve: _d ? Curves.fastLinearToSlowEaseIn : Curves.elasticOut,
              height: _d ? 0 : _a ? _h / 2 : 40,
              width: 40,
            ),
            AnimatedContainer(
              duration: Duration(
                  seconds: _d ? 1 : _c ? 2 : 0),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _d ? _h : _c ? 80 : 20,
              width: _d ? _w : _c ? 200 : 20,
              decoration: BoxDecoration(
                  color: _b ?  Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                  borderRadius: _d ? BorderRadius.only() : BorderRadius.circular(30)
              ),
              child: Center(
                child: _e
                    ? Container(
                  width: _w * 0.6,  // Adjust the width as needed
                  height: _h * 0.3, // Adjust the height as needed
                  child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: AnimatedTextKit(
                        totalRepeatCount: 1,
                        animatedTexts: [
                          FadeAnimatedText(
                            'GamerGrove',
                            duration: Duration(milliseconds: 1700),
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThisIsFadeRoute extends PageRouteBuilder {
  Widget? page;
  Widget? route;

  ThisIsFadeRoute({this.page, this.route})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page!,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: route,
          ),
        );
}

