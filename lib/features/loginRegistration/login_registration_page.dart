import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/features/loginRegistration/login/view/login_page.dart';
import 'package:gamer_grove/features/loginRegistration/signup/view/signup_page.dart';


class LoginRegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Anzahl der Tabs (Login und Signup)
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Signup'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginPage(), // Hier setzt du die View für den Login
            SignupPage(), // Hier setzt du die View für die Registrierung
          ],
        ),
      ),
    );
  }
}
