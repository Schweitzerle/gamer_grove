import 'package:auth_service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/features/loginRegistration/signup/view/signup_view.dart';

import '../bloc/signup_bloc.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseAuthService>(
          create: (context) => FirebaseAuthService(
            authService: FirebaseAuth.instance,
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) => SignupBloc(
          authService: context.read<FirebaseAuthService>(),
        ),
        child: SignUpView(),
      ),
    );
  }
}
