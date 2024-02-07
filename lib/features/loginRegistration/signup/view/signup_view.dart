import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/features/landingScreen/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';

import '../../../home/home_screen.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CreateAccountName(),
            const SizedBox(height: 15.0),
            _CreateAccountUsername(),
            const SizedBox(height: 15.0),
            _ProfilePicturePicker(),
            const SizedBox(height: 30.0),
            _CreateAccountEmail(),
            const SizedBox(height: 15.0),
            _CreateAccountPassword(),
            const SizedBox(height: 30.0),
            _SubmitButton(),
          ],
        ),
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
        onChanged: (value) => context
            .read<SignupBloc>()
            .add(SignupNameChangedEvent(name: value)),
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
  File? _pickedImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _pickImage();
      },
      child: CircleAvatar(
        radius: 40.0,
        backgroundColor: Colors.blue,
        backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
        child: _pickedImage == null ? Icon(Icons.camera_alt, size: 24.0) : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {

      setState(() {
        _pickedImage = File(pickedImage.path);
        context.read<SignupBloc>().add(SignupProfilePictureChangedEvent(profilePicture: _pickedImage));
      });
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

class _CreateAccountPassword extends StatelessWidget {
  _CreateAccountPassword({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: TextField(
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Password',
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
            SignupButtonPressedEvent(),
          ),
      child: const Text('Create Account'),
    );
  }
}
