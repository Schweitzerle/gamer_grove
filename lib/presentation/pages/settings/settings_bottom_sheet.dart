import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_access.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:gamer_grove/presentation/pages/settings/theme_selection_dialog.dart';
import 'package:gamer_grove/presentation/pages/settings/widgets/theme_card.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// GamerGrove Pro entry in settings. Reactively shows an upsell for free users
/// and an "active + manage subscription" tile for Pro users.
class _UpgradeProTile extends StatelessWidget {
  const _UpgradeProTile();

  @override
  Widget build(BuildContext context) {
    final service = sl<EntitlementService>();
    return StreamBuilder<Entitlements>(
      stream: service.changes,
      initialData: service.entitlements,
      builder: (context, snapshot) {
        final isPro = (snapshot.data ?? const Entitlements.free()).isPro;
        return isPro ? const _ProActiveTile() : const _ProUpsellTile();
      },
    );
  }
}

/// Opens the Google Play subscriptions page so the user can manage/cancel.
Future<void> _openManageSubscription() async {
  final uri = Uri.parse('https://play.google.com/store/account/subscriptions');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _ProUpsellTile extends StatelessWidget {
  const _ProUpsellTile();

  @override
  Widget build(BuildContext context) {
    return _ProGradientTile(
      semanticsLabel: 'Upgrade to GamerGrove Pro',
      leading: Icons.workspace_premium,
      title: 'GamerGrove Pro',
      subtitle: 'Unlock stats, collections & more',
      trailing: Icons.chevron_right,
      onTap: () => Navigations.navigateToPaywall(context, source: 'settings'),
    );
  }
}

class _ProActiveTile extends StatelessWidget {
  const _ProActiveTile();

  @override
  Widget build(BuildContext context) {
    return const _ProGradientTile(
      semanticsLabel: 'GamerGrove Pro active. Manage subscription',
      leading: Icons.verified,
      title: 'GamerGrove Pro · Active',
      subtitle: 'Manage subscription',
      trailing: Icons.open_in_new,
      onTap: _openManageSubscription,
    );
  }
}

/// Shared gradient tile used for both the upsell and active states.
class _ProGradientTile extends StatelessWidget {
  const _ProGradientTile({
    required this.semanticsLabel,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String semanticsLabel;
  final IconData leading;
  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
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
              Icon(leading, color: scheme.onPrimary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailing, color: scheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
