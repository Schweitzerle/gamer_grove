import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';

import '../../blocs/auth/auth_bloc.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
      ),
      body: const Center(
        child: Text('Coming soon'),
      ),
    );
  }
}
