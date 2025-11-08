import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:gamer_grove/presentation/pages/settings/about_us_page.dart';

import 'package:gamer_grove/presentation/pages/settings/theme_selection_dialog.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = 'settings-page';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(
                        ThemeModeChanged(
                            value ? ThemeMode.dark : ThemeMode.light),
                      );
                },
              ),
              ListTile(
                title: const Text('Theme'),
                onTap: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (context) => const ThemeSelectionDialog(),
                  );
                },
              ),
              ListTile(
                title: const Text('About Us'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => const AboutUsPage(),
                  ));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
