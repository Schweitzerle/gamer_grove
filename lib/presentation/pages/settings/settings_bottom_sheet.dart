import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_access.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:gamer_grove/presentation/pages/legal/legal_document_page.dart';
import 'package:gamer_grove/presentation/pages/settings/theme_selection_dialog.dart';
import 'package:gamer_grove/presentation/widgets/app_version_line.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        // Scrollable, and sized to its content. Without this the sheet is
        // capped at 9/16 of the screen and the last 166dp — the IGDB notice
        // and the version line — sit below the bottom edge with no way to
        // reach them. That is why the line saying "v2.0.0" went three releases
        // without anyone noticing it was wrong: nobody could see it.
        return SafeArea(
          child: SingleChildScrollView(
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
                  // A preview, not a control: the ListTile is the tap target.
                  // This used to be a ThemeCard with an empty callback, i.e. a
                  // button that announced itself to screen readers and did
                  // nothing.
                  trailing: const _ThemePreview(),
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
                const _LegalLinks(),
                const SizedBox(height: 8),
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
                const AppVersionLine(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Three dots of the theme that is currently applied — primary, secondary,
/// tertiary. Decorative, so it stays out of the semantics tree; the row it
/// sits in already describes and handles the action.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.ggTokens;

    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: tokens.spaceXs,
        children: [
          for (final color in <Color>[
            scheme.primary,
            scheme.secondary,
            scheme.tertiary,
          ])
            Container(
              width: tokens.spaceLg,
              height: tokens.spaceLg,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outlineVariant),
              ),
            ),
        ],
      ),
    );
  }
}

/// Privacy policy and imprint. Both must be reachable from inside the app:
/// the imprint is required for a German business (§ 5 DDG) and Play expects the
/// privacy policy to be available to users, not only in the store listing.
class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => unawaited(
            Navigator.of(context).push(
              LegalDocumentPage.route(LegalDocument.privacyPolicy),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('AGB'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => unawaited(
            Navigator.of(context).push(
              LegalDocumentPage.route(LegalDocument.agb),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Datenschutz & Impressum'),
          subtitle: const Text('Deutsche Fassung'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => unawaited(_showGermanLegal(context)),
        ),
      ],
    );
  }

  /// The German privacy policy is the binding version, so it is offered
  /// together with the imprint it belongs to.
  Future<void> _showGermanLegal(BuildContext context) async {
    final choice = await showModalBottomSheet<LegalDocument>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Datenschutzerklärung'),
              onTap: () => Navigator.of(context).pop(LegalDocument.datenschutz),
            ),
            ListTile(
              title: const Text('Impressum'),
              onTap: () => Navigator.of(context).pop(LegalDocument.impressum),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    await Navigator.of(context).push(LegalDocumentPage.route(choice));
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
      subtitle: 'Unlock stats, filters, themes & unlimited collections',
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
