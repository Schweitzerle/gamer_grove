import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../test/igdb_test_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutEvent());
            },
          ),
        ],
      ),
      body: user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.username[0].toUpperCase(),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (user.displayName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.displayName!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],

                  // Debug info
                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debug Info',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('User ID: ${user.id}'),
                            Text('Created: ${user.createdAt}'),
                            Text(
                              'Wishlisted Games: ${user.totalGamesWishlisted}',
                            ),
                            Text(
                              'Rated Games: ${user.totalGamesRated}',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => const IGDBTestPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.api),
                              label: const Text('Test IGDB API'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const Center(
              child: Text('Not logged in'),
            ),
    );
  }
}
