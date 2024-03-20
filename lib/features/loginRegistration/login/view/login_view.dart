import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/features/landingScreen/bottom_nav_bar.dart';

import '../../../home/home_screen.dart';
import '../../signup/view/signup_page.dart';
import '../bloc/login_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).pushReplacement(LiquidTabBar.route());
        }
        if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LoginEmail(),
            const SizedBox(height: 30.0),
            _LoginPassword(),
            const SizedBox(height: 30.0),
            _SubmitButton(),
            const SizedBox(height: 30.0),
            const _CreateAccountButton(),
          ],
        ),
      ),
    );
  }
}

class _LoginEmail extends StatelessWidget {
  _LoginEmail({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: TextField(
        onChanged: ((value) {
          context.read<LoginBloc>().add(LoginEmailChangedEvent(email: value));
        }),
        decoration: const InputDecoration(hintText: 'Email'),
      ),
    );
  }
}

class _LoginPassword extends StatefulWidget {
  const _LoginPassword({
    Key? key,
  }) : super(key: key);

  @override
  State<_LoginPassword> createState() => _LoginPasswordState();
}

class _LoginPasswordState extends State<_LoginPassword> {
  bool _passwordVisible = true;

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: TextField(
        onChanged: ((value) {
          context
              .read<LoginBloc>()
              .add(LoginPasswordChangedEvent(password: value));
        }),
        obscureText: _passwordVisible,
        decoration: InputDecoration(
          hintText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  _SubmitButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<LoginBloc>().add(
              LoginButtonPressedEvent(),
            );
      },
      child: const Text('Login'),
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SignupPage(),
          ),
        );
      },
      child: const Text('Create Account'),
    );
  }
}
