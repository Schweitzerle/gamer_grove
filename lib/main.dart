
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auth_service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/features/landingScreen/bottom_nav_bar.dart';
import 'package:gamer_grove/features/loginRegistration/login_registration_page.dart';
import 'package:gamer_grove/features/loginRegistration/login/view/login_page.dart';
import 'package:gamer_grove/features/loginRegistration/signup/view/signup_page.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/repository/firebase/firebase.dart';
import 'package:gamer_grove/repository/igdb/AppTokenService.dart';
import 'package:gamer_grove/utils/ThemManager.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:motion/motion.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/home/home_screen.dart';
import 'features/loginRegistration/login/bloc/login_bloc.dart';
import 'features/splashScreen/splash_screen.dart';
import 'firebase_options.dart';
import 'model/firebase/firebaseUser.dart';

void main() async {
  //TODO: vllt systemchrome verschieben, wegen null value error
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppTokenService.getAppToken();
  await Motion.instance.initialize();
  Motion.instance.setUpdateInterval(60.fps);
  Future.wait([registerCurrentUserData()]);
  runApp(
      GetMaterialApp(
        title: 'CouchCinema',
        debugShowCheckedModeBanner: false,
        home: GamerGroveApp(),
      ),
  );
}

Future<void> registerCurrentUserData() async {
  final currentUser = await FirebaseService().getSingleCurrentUserData();
  final getIt = GetIt.instance;
  getIt.allowReassignment = true;
  getIt.registerSingletonAsync<FirebaseUserModel>(() => Future.value(currentUser),
  );  }

class GamerGroveApp extends StatefulWidget {
  GamerGroveApp({Key? key}) : super(key: key);

  @override
  _GamerGroveAppState createState() => _GamerGroveAppState();
}

class _GamerGroveAppState extends State<GamerGroveApp> {

  late Future<FlexScheme> _storedSchemeFuture;

  @override
  void initState() {
    super.initState();
    _storedSchemeFuture = _loadAndSetTheme();
  }

  Future<FlexScheme> _loadAndSetTheme() async {
    final storedScheme = await ThemeManager().loadThemeFromPrefs();
    return storedScheme;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlexScheme>(
      future: _storedSchemeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Placeholder while loading
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final storedScheme = snapshot.data!;
            return AdaptiveTheme(
              initial: AdaptiveThemeMode.system,
              light: FlexThemeData.light(
                scheme: storedScheme,
                surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
                blendLevel: 7,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 10,
                  blendOnColors: false,
                  useTextTheme: true,
                  useM2StyleDividerInM3: true,
                  alignedDropdown: true,
                  useInputDecoratorThemeInDialogs: true,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
                swapLegacyOnMaterial3: true,
              ),
              dark: FlexThemeData.dark(
                scheme: storedScheme,
                surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
                blendLevel: 13,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 20,
                  useTextTheme: true,
                  useM2StyleDividerInM3: true,
                  alignedDropdown: true,
                  useInputDecoratorThemeInDialogs: true,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
                swapLegacyOnMaterial3: true,
              ),
              builder: (theme, darkTheme) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Gamer Grove',
                theme: theme,
                darkTheme: darkTheme,
                home: SplashScreen(),
              ),
            );
          }
        }
      },
    );
  }
}
