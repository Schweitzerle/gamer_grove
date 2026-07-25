import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/pages/settings/theme_selection_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  /// Opens the picker the way the app does. Rendering an `AlertDialog`
  /// straight into a Scaffold body instead lets the grid paint outside the
  /// dialog surface, so the contrast guideline measures text against whatever
  /// happens to sit behind it — a layout that never ships.
  Future<ThemeBloc> pumpDialog(WidgetTester tester) async {
    final bloc = ThemeBloc();
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: GGTheme.dark(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: const ThemeSelectionDialog(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('offers the brand theme alongside the FlexColorScheme options',
      (tester) async {
    await pumpDialog(tester);

    // The brand theme is not a FlexScheme, so it would be missing entirely if
    // the extra tile were dropped — and the picker would have no way back to
    // the app's own colours.
    expect(find.bySemanticsLabel('GamerGrove'), findsOneWidget);
  });

  testWidgets('picking the brand theme clears the stored scheme',
      (tester) async {
    final bloc = await pumpDialog(tester);
    bloc.add(const ThemeSchemeChanged(FlexScheme.mango));
    await tester.pumpAndSettle();
    expect(bloc.state.flexScheme, FlexScheme.mango);

    await tester.tap(find.bySemanticsLabel('GamerGrove'));
    await tester.pumpAndSettle();

    expect(bloc.state.usesBrandTheme, isTrue);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDialog(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
