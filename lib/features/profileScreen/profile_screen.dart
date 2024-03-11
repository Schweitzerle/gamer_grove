import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auth_service/auth.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/firebase/firebaseUser.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/repository/firebase/firebase.dart';
import 'package:get_it/get_it.dart';
import 'package:profile_view/profile_view.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

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
  final getIt = GetIt.instance;

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

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ThemeScreen()),
    );
    setState(() {
      _storedSchemeFuture = _loadAndSetTheme();
    });
  }

  int getRatedGameKeys(Map<String, dynamic> games) {
    final recommendedGames = games.entries.where((entry) => entry.value['rating'] > 0);
    return recommendedGames.map((entry) => entry.key).toList().length;
  }

  int getRecommendedGameKeys(Map<String, dynamic> games) {
    final recommendedGames = games.entries.where((entry) => entry.value['recommended'] == true);
    return recommendedGames.map((entry) => entry.key).toList().length;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    final bannerScaleHeight = mediaQueryHeight * 0.3;
    final user = getIt<FirebaseUserModel>();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: mediaQueryHeight * .74,
            width: mediaQueryWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.0, 1),
                // Start at the middle left
                end: Alignment(0.0, 0.1),
                // End a little above two thirds of the height
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.inversePrimary,
                ],
                stops: [
                  0.67,
                  1.0
                ], // Stop the gradient at approximately two thirds of the height
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
                Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          WidgetCircularAnimator(
                            outerColor: Theme.of(context).colorScheme.primary,
                            innerColor: Theme.of(context).colorScheme.secondary,
                            outerAnimation: Curves.linear,
                            child: ProfileView(
                              height: 100,
                              width: 100,
                              circle: false,
                              borderRadius: 90,
                              image: NetworkImage(
                                getIt<FirebaseUserModel>().profileUrl,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user!.username,
                            // Hier den tatsächlichen Benutzernamen einfügen
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        'Followers', // Anzahl der Follower einfügen
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                      user.followers.length.toString(),
                                      // Anzahl der Follower einfügen
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        'Following',
                                        // Anzahl der Abonnements einfügen
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                      user.following.length.toString(),
                                      // Anzahl der Abonnements einfügen
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        'Games Rated',
                                        // Anzahl der bewerteten Spiele einfügen
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                      getRatedGameKeys(user.games).toString(),
                                      // Anzahl der bewerteten Spiele einfügen
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        'Games Recommended',
                                        // Anzahl der bewerteten Spiele einfügen
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                      getRecommendedGameKeys(user.games).toString(),
                                      // Anzahl der bewerteten Spiele einfügen
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
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
                                          onPressed: () async {
                                            _navigateAndDisplaySelection(
                                                context);
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
                                                  selectedCountry =
                                                      country.name;
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
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
