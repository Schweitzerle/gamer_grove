import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auth_service/auth.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';

import '../../model/views/theme_screen.dart';
import '../../model/widgets/ThemeButton.dart';
import '../../utils/ThemManager.dart';
import '../loginRegistration/login/bloc/login_bloc.dart';
import '../loginRegistration/login_registration_page.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<FlexScheme> _storedSchemeFuture;
  late StreamSubscription<void> _themeChangeSubscription;

  @override
  void initState() {
    super.initState();
    _storedSchemeFuture = _loadAndSetTheme();

    //TODO: Listener funtioniert nicht
    _themeChangeSubscription = ThemeManager().onThemeChanged.listen((_) {
      setState(() {
        _storedSchemeFuture = _loadAndSetTheme();
        print('received theme change notification');
      });
    });
  }

  @override
  void dispose() {
    _themeChangeSubscription.cancel();
    super.dispose();
  }

  Future<FlexScheme> _loadAndSetTheme() async {
    final storedScheme = await ThemeManager().loadThemeFromPrefs();
    return storedScheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              FirebaseAuthService(authService: FirebaseAuth.instance).signOut();
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiRepositoryProvider(
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
                  ),
                ),
                    (route) => false,
              );
            },
            child: Text('Logout'),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClayContainer(
                  spread: 2,
                  height: MediaQuery.of(context).size.height * .18,
                  customBorderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClayContainer(
                                  spread: 2,
                                  customBorderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context).cardColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'Current Theme',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).cardTheme.surfaceTintColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ThemeScreen()),
                                      );
                                    },
                                    child: Text('View All Themes'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: FutureBuilder<FlexScheme>(
                            future: _storedSchemeFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final scheme = snapshot.data!;
                                  return ThemeButton(
                                    scheme: scheme,
                                    themeName: scheme.toString().split('.').last,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
