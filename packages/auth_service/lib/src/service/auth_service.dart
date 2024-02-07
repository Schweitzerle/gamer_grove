
import 'dart:io';

import '../../auth.dart';

abstract class AuthService {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String name,
    File? profilePicture,
  });
}
