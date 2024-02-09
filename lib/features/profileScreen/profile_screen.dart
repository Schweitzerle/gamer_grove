import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auth_service/auth.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:profile_view/profile_view.dart';

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
  String selectedCountry = 'English';

  @override
  void initState() {
    super.initState();
    _storedSchemeFuture = _loadAndSetTheme();

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
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    final bannerScaleHeight = mediaQueryHeight * 0.3;

    return Scaffold(
      body: Stack(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.background,
                ],
                stops: [0.1, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.darken,
            child: Container(
              width: mediaQueryWidth,
              height: bannerScaleHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 40, right: 14),
              child: ElevatedButton(
                onPressed: () async {
                  FirebaseAuthService(authService: FirebaseAuth.instance)
                      .signOut();
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 38.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                const ProfileView(
                  height: 100,
                  width: 100,
                  circle: false,
                  borderRadius: 14,
                  image: NetworkImage(
                      "https://preview.keenthemes.com/metronic-v4/theme/assets/pages/media/profile/profile_user.jpg"),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Username', // Hier den tatsächlichen Benutzernamen einfügen
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Followers', // Anzahl der Follower einfügen
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '100', // Anzahl der Follower einfügen
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          'Following', // Anzahl der Abonnements einfügen
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '50', // Anzahl der Abonnements einfügen
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          'Games Rated',
                          // Anzahl der bewerteten Spiele einfügen
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '200', // Anzahl der bewerteten Spiele einfügen
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClayContainer(
                        spread: 2,
                        depth: 60,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ClayContainer(
                                        spread: 2,
                                        depth: 60,
                                        customBorderRadius:
                                            BorderRadius.circular(12),
                                        color: Theme.of(context).cardColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              'Current Theme',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .cardTheme
                                                    .surfaceTintColor,
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
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ThemeScreen()),
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
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        final scheme = snapshot.data!;
                                        return ThemeButton(
                                          scheme: scheme,
                                          themeName:
                                              scheme.toString().split('.').last,
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
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClayContainer(
                        spread: 2,
                        depth: 60,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ClayContainer(
                                        spread: 2,
                                        depth: 60,
                                        customBorderRadius:
                                            BorderRadius.circular(12),
                                        color: Theme.of(context).cardColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              'Current Language',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .cardTheme
                                                    .surfaceTintColor,
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
                                            showCountryPicker(
                                              context: context,
                                              countryListTheme:
                                                  CountryListThemeData(
                                                      bottomSheetHeight:
                                                          mediaQueryHeight * .7,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .inversePrimary),
                                              showPhoneCode: false,
                                              // optional. Shows phone code before the country name.
                                              onSelect: (Country country) {
                                                setState(() {
                                                  //TODO: in sharedprefs speichern und auch die localization anpassen (Translate)
                                                  selectedCountry = country.name;
                                                });
                                              },
                                            );
                                          },
                                          child: Text('Change Language'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: ClayContainer(
                                  spread: 2,
                                  depth: 60,
                                  customBorderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        selectedCountry,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .cardTheme
                                              .surfaceTintColor,
                                        ),
                                      ),
                                    ),
                                  ),
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
          ),
        ],
      ),
    );
  }
}
