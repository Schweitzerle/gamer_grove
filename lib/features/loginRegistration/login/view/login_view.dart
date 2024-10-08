import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/features/landingScreen/bottom_nav_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
import 'package:vitality/models/ItemBehaviour.dart';
import 'package:vitality/models/WhenOutOfScreenMode.dart';
import 'package:vitality/vitality.dart';

import '../../../../model/firebase/firebaseUser.dart';
import '../../../../repository/firebase/firebase.dart';
import '../../../home/home_screen.dart';
import '../../signup/view/signup_page.dart';
import '../bloc/login_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> registerCurrentUserData() async {
    final getIt = GetIt.instance;
    final currentUser = await FirebaseService().getSingleCurrentUserData();
    getIt.allowReassignment = true;
    getIt.registerSingletonAsync<FirebaseUserModel>(
          () => Future.value(currentUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Future.wait([registerCurrentUserData()]);
          Color color = Theme.of(context).colorScheme.primaryContainer;
          ToastService.showToast(
            context,
            isClosable: true,
            backgroundColor: color,
            shadowColor: color.darken(20),
            length: ToastLength.medium,
            expandedHeight: 100,
            message: "Logged in successfully! 🤗",
            messageStyle: TextStyle(color: color.onColor),
            leading: GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('1.', style: TextStyle(color: color.onColor, fontWeight: FontWeight.bold),),
                )),
            slideCurve: Curves.elasticInOut,
            positionCurve: Curves.bounceOut,
            dismissDirection: DismissDirection.none,
          );
          Navigator.of(context).pushReplacement(LiquidTabBar.route());
        }
        if (state.status == LoginStatus.failure) {
          Color color = Theme.of(context).colorScheme.tertiaryContainer;
          ToastService.showToast(
            context,
            isClosable: true,
            backgroundColor: color,
            shadowColor: color.darken(20),
            length: ToastLength.medium,
            expandedHeight: 100,
            message: "${state.message}! 🙃",
            messageStyle: TextStyle(color: color.onColor),
            leading: GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('1.', style: TextStyle(color: color.onColor, fontWeight: FontWeight.bold),),
                )),
            slideCurve: Curves.elasticInOut,
            positionCurve: Curves.bounceOut,
            dismissDirection: DismissDirection.none,
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
      body: Stack(
        children: [
          Vitality.randomly(
            background: Theme.of(context).colorScheme.background,
            maxOpacity: 0.8,
            minOpacity: 0.3,
            itemsCount: 80,
            enableXMovements: false,
            whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
            maxSpeed: 0.1,
            maxSize: 30,
            minSpeed: 0.1,
            randomItemsColors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.onPrimary
            ],
            randomItemsBehaviours: [
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: Icons.login),
              ItemBehaviour(shape: ShapeType.Icon, icon: CupertinoIcons.profile_circled),
              ItemBehaviour(shape: ShapeType.Icon, icon: FontAwesomeIcons.registered),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: CupertinoIcons.signature),
              ItemBehaviour(
                  shape: ShapeType.Icon,
                  icon: Icons.password_rounded),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: CupertinoIcons.tv),
              ItemBehaviour(shape: ShapeType.StrokeCircle),
            ],
          ),
          Center(
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
        ],
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
              const LoginButtonPressedEvent(),
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
    return ElevatedButton(
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
