// firebase_auth_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth.dart';
import '../models/models.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    required auth.FirebaseAuth authService,
  }) : _firebaseAuth = authService;

  final auth.FirebaseAuth _firebaseAuth;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final db = FirebaseFirestore.instance;

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
    XFile? profilePicture,
  }) async {
    try {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = authResult.user;
      final userID = user!.uid;
      final ref = firebase_storage.FirebaseStorage.instance
          .ref('userProfileImages/${userID}')
          .child(profilePicture!.name);
      final uploadTask = ref.putFile(File(profilePicture.path));

      await uploadTask.whenComplete(() => null);

      final profileURL = await ref.getDownloadURL();


      await storeUserDataInDatabase(
        userId: userID,
        email: email,
        username: username,
        name: name,
        profilePictureURL: profileURL,
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
    String? profilePictureURL,
  }) async {

    if (profilePictureURL != null) {
      await db.collection('Users').doc(userId).set({'id': userId,
        'email': email,
        'username': username,
        'name': name,
        'profilePicture': profilePictureURL,});
    }

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
