// firebase_auth_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../auth.dart';
import '../models/models.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    required auth.FirebaseAuth authService,
  }) : _firebaseAuth = authService;

  final auth.FirebaseAuth _firebaseAuth;

  UserEntity _mapFirebaseUser(auth.User? user) {
    if (user == null) {
      return UserEntity.empty();
    }

    // Your existing code to map Firebase user to UserEntity
    var splittedName = ['Name ', 'LastName'];
    if (user.displayName != null) {
      splittedName = user.displayName!.split(' ');
    }

    final map = <String, dynamic>{
      'id': user.uid,
      'firstName': splittedName.first,
      'lastName': splittedName.last,
      'email': user.email ?? '',
      'emailVerified': user.emailVerified,
      'imageUrl': user.photoURL ?? '',
      'isAnonymous': user.isAnonymous,
      'age': 0,
      'phoneNumber': '',
      'address': '',
    };
    return UserEntity.fromJson(map);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _mapFirebaseUser(userCredential.user!);
    } on auth.FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  @override
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String name,
    File? profilePicture,
  }) async {
    try {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = authResult.user;
      await storeUserDataInDatabase(
        userId: user!.uid,
        email: email,
        username: username,
        name: name,
        profilePicture: profilePicture,
      );

      return _mapFirebaseUser(user!);
    } on FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  Future<void> storeUserDataInDatabase({
    required String userId,
    required String email,
    required String username,
    required String name,
    File? profilePicture,
  }) async {
    final databaseReference = FirebaseDatabase.instance.reference();


    final File imageFile = File(profilePicture!.path);
    final List<int> imageBytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(imageBytes);

    await databaseReference.child('users').child(userId).set({
      'email': email,
      'username': username,
      'name': name,
      'profilePicture': base64Image,
    });
  }


  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return _mapFirebaseUser(user);
  }


  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  AuthError _determineError(auth.FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return AuthError.invalidEmail;
      case 'user-disabled':
        return AuthError.userDisabled;
      case 'user-not-found':
        return AuthError.userNotFound;
      case 'wrong-password':
        return AuthError.wrongPassword;
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return AuthError.emailAlreadyInUse;
      case 'invalid-credential':
        return AuthError.invalidCredential;
      case 'operation-not-allowed':
        return AuthError.operationNotAllowed;
      case 'weak-password':
        return AuthError.weakPassword;
      case 'ERROR_MISSING_GOOGLE_AUTH_TOKEN':
      default:
        return AuthError.error;
    }
  }
}
