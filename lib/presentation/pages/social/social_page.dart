import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';

class SocialPage extends StatelessWidget {
  const SocialPage();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is Authenticated ? state.user : null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
      ),
      body: Center(child: Text('Coming soon'),),
    );
  }
}