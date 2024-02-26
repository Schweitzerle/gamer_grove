
import 'dart:io';

import 'package:image_picker/image_picker.dart';

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
    XFile? profilePicture,
  });
}
