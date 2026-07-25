import 'package:bloc_test/bloc_test.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The brand theme is not a `FlexScheme`, so it has no enum index to store.
/// Getting that mapping wrong is invisible until an existing install opens the
/// app and finds a different theme than it left, which is what these cover.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('starts on the brand theme, not on a FlexScheme', () {
    expect(ThemeState.initial().flexScheme, isNull);
    expect(ThemeState.initial().usesBrandTheme, isTrue);
    expect(ThemeState.initial().themeMode, ThemeMode.dark);
  });

  group('loading a stored preference', () {
    blocTest<ThemeBloc, ThemeState>(
      'a fresh install gets the brand theme',
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadStarted()),
      expect: () => [
        isA<ThemeState>().having((s) => s.usesBrandTheme, 'brand', isTrue),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'a user who picked a scheme keeps it',
      setUp: () => SharedPreferences.setMockInitialValues(
        <String, Object>{'flexScheme': FlexScheme.sakura.index},
      ),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadStarted()),
      expect: () => [
        isA<ThemeState>()
            .having((s) => s.flexScheme, 'scheme', FlexScheme.sakura),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'the brand marker resolves back to the brand theme',
      setUp: () => SharedPreferences.setMockInitialValues(
        <String, Object>{'flexScheme': -1},
      ),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadStarted()),
      expect: () => [
        isA<ThemeState>().having((s) => s.usesBrandTheme, 'brand', isTrue),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'an index this build no longer knows falls back instead of crashing',
      setUp: () => SharedPreferences.setMockInitialValues(
        <String, Object>{'flexScheme': 9999},
      ),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadStarted()),
      expect: () => [
        isA<ThemeState>().having((s) => s.usesBrandTheme, 'brand', isTrue),
      ],
    );
  });

  group('changing the scheme', () {
    blocTest<ThemeBloc, ThemeState>(
      'picking a scheme stores its index',
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeSchemeChanged(FlexScheme.mango)),
      expect: () => [
        isA<ThemeState>()
            .having((s) => s.flexScheme, 'scheme', FlexScheme.mango),
      ],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('flexScheme'), FlexScheme.mango.index);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'going back to the brand theme clears the scheme',
      seed: () => const ThemeState(
        themeMode: ThemeMode.dark,
        flexScheme: FlexScheme.mango,
      ),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeSchemeChanged(null)),
      expect: () => [
        isA<ThemeState>().having((s) => s.usesBrandTheme, 'brand', isTrue),
      ],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('flexScheme'), -1);
      },
    );
  });

  test('copyWith cannot accidentally clear the scheme', () {
    // `flexScheme: null` in copyWith means "leave it alone", which is why
    // clearing needs its own flag rather than passing null.
    const picked = ThemeState(
      themeMode: ThemeMode.dark,
      flexScheme: FlexScheme.mango,
    );
    expect(
      picked.copyWith(themeMode: ThemeMode.light).flexScheme,
      FlexScheme.mango,
    );
    expect(picked.copyWith(resetToBrandTheme: true).flexScheme, isNull);
  });
}
