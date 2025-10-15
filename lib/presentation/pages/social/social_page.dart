import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is Authenticated ? state.user : null;
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
