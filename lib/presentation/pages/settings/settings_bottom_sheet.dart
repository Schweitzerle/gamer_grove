import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/entitlements/pro_access.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:gamer_grove/presentation/pages/settings/theme_selection_dialog.dart';
import 'package:gamer_grove/presentation/pages/settings/widgets/theme_card.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const _UpgradeProTile(),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Mode'),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {state.themeMode},
                  onSelectionChanged: (newSelection) {
                    context
                        .read<ThemeBloc>()
                        .add(ThemeModeChanged(newSelection.first));
                  },
                ),
              ),
              ListTile(
                title: const Text('Theme'),
                trailing: SizedBox(
                  width: 100,
                  height: 60,
                  child: ThemeCard(
                    scheme: state.flexScheme,
                    isSelected: false, // not selectable here
                    onSelect: (_) {},
                  ),
                ),
                onTap: () async {
                  // Theme customization is a Pro feature; free users get the
                  // paywall, Pro users get the theme picker.
                  if (!await requirePro(context, source: 'settings_theme')) {
                    return;
                  }
                  if (!context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (context) => const ThemeSelectionDialog(),
                  );
                },
              ),
              const Spacer(),
              const Divider(),
              const SizedBox(height: 8),
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    height: 40,
                    child: Image.asset('assets/images/igdb_logo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This app uses the IGDB API but is not endorsed or certified by IGDB.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(
                'GamerGrove v2.0.0',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Prominent entry point into the GamerGrove Pro paywall.
class _UpgradeProTile extends StatelessWidget {
  const _UpgradeProTile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Upgrade to GamerGrove Pro',
      child: InkWell(
        onTap: () => Navigations.navigateToPaywall(context, source: 'settings'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.tertiary],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.workspace_premium, color: scheme.onPrimary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GamerGrove Pro',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Unlock stats, collections & more',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
