import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/features/landingScreen/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:vitality/models/ItemBehaviour.dart';
import 'package:vitality/vitality.dart';
import '../bloc/signup_bloc.dart';

class SignUpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.status == SignupStatus.success) {
          Navigator.of(context).pushReplacement(LiquidTabBar.route());
        }
        if (state.status == SignupStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: const _SignupForm(),
    );
  }
}

class _SignupForm extends StatelessWidget {
  const _SignupForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 8.0,
                  right: 8,
                  top: MediaQuery.of(context).size.height * .15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _ProfilePicturePicker(),
                  const SizedBox(height: 15.0),
                  const Row(
                    children: [
                      Expanded(child: _CreateAccountName()),
                      SizedBox(width: 15.0),
                      Expanded(child: _CreateAccountUsername()),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    children: [
                      Expanded(child: _CreateAccountEmail()),
                      const SizedBox(width: 15.0),
                      Expanded(child: _CreateAccountPassword()),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  _SubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateAccountName extends StatelessWidget {
  const _CreateAccountName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: TextField(
        onChanged: (value) =>
            context.read<SignupBloc>().add(SignupNameChangedEvent(name: value)),
        decoration: const InputDecoration(hintText: 'Name'),
      ),
    );
  }
}

class _CreateAccountUsername extends StatelessWidget {
  const _CreateAccountUsername({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: TextField(
        onChanged: (value) => context
            .read<SignupBloc>()
            .add(SignupUsernameChangedEvent(username: value)),
        decoration: const InputDecoration(hintText: 'Username'),
      ),
    );
  }
}

class _ProfilePicturePicker extends StatefulWidget {
  const _ProfilePicturePicker({Key? key}) : super(key: key);

  @override
  _ProfilePicturePickerState createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<_ProfilePicturePicker> {
  File? _photo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _pickImage();
      },
      child: CircleAvatar(
        radius: 40.0,
        backgroundImage: _photo != null ? FileImage(_photo!) : null,
        child: _photo == null ? Icon(Icons.camera_alt, size: 24.0) : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _photo = File(pickedImage.path);
        context
            .read<SignupBloc>()
            .add(SignupProfilePictureChangedEvent(profilePicture: pickedImage));
      });
    }
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = 'jdhfskjh';
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occured');
    }
  }
}

class _CreateAccountEmail extends StatelessWidget {
  _CreateAccountEmail({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: TextField(
        onChanged: (value) => context
            .read<SignupBloc>()
            .add(SignupEmailChangedEvent(email: value)),
        decoration: const InputDecoration(hintText: 'Email'),
      ),
    );
  }
}

class _CreateAccountPassword extends StatefulWidget {
  const _CreateAccountPassword({
    Key? key,
  }) : super(key: key);

  @override
  State<_CreateAccountPassword> createState() => _CreateAccountPasswordState();
}

class _CreateAccountPasswordState extends State<_CreateAccountPassword> {
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
        obscureText: _passwordVisible,
        decoration: InputDecoration(
          hintText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        onChanged: (value) => context
            .read<SignupBloc>()
            .add(SignupPasswordChangedEvent(password: value)),
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
      onPressed: () => context.read<SignupBloc>().add(
            const SignupButtonPressedEvent(),
          ),
      child: const Text('Create Account'),
    );
  }
}
