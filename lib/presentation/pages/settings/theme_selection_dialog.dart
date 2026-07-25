import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/theme/gg_color_schemes.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/pages/settings/widgets/theme_card.dart';

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedScheme = context.watch<ThemeBloc>().state.flexScheme;
    final tokens = context.ggTokens;

    void select(FlexScheme? scheme) {
      context.read<ThemeBloc>().add(ThemeSchemeChanged(scheme));
      Navigator.of(context).pop();
    }

    // Deliberately a `Dialog` and not an `AlertDialog`. With 40+ schemes the
    // grid inside an AlertDialog's `content` kept painting over the actions —
    // the Close button ended up sitting on top of a theme tile. A min-height
    // Column with the grid in a `Flexible` gives the grid whatever space is
    // left after the title and the button, and it cannot claim more.
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: tokens.spaceMd,
            children: [
              Text(
                'Select Theme',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Flexible(
                child: GridView.builder(
                  // One extra tile at the front: the brand theme, which is the
                  // default and is not one of FlexColorScheme's schemes.
                  itemCount: FlexScheme.values.length + 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: tokens.spaceSm,
                    mainAxisSpacing: tokens.spaceSm,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ThemeCard(
                        colorScheme: GGColorSchemes.dark,
                        label: 'GamerGrove',
                        isSelected: selectedScheme == null,
                        onSelect: () => select(null),
                      );
                    }

                    final scheme = FlexScheme.values[index - 1];
                    return ThemeCard(
                      colorScheme:
                          FlexThemeData.light(scheme: scheme).colorScheme,
                      label: scheme.name[0].toUpperCase() +
                          scheme.name.substring(1),
                      isSelected: scheme == selectedScheme,
                      onSelect: () => select(scheme),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
