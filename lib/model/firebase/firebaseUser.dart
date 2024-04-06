import 'package:auth_service/auth.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/views/otherUserProfileView.dart';
import 'package:gamer_grove/repository/firebase/firebase.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:profile_view/profile_view.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

import 'gameModel.dart';

class FirebaseUserModel extends ChangeNotifier {
  final String uuid;
  final String name;
  final String username;
  final String email;
  Map<String, dynamic> games;
  final Map<dynamic, dynamic> following; // Change type to List<String>
  final Map<dynamic, dynamic> followers; // Change type to List<String>
  final String profileUrl;

  FirebaseUserModel({
    required this.uuid,
    required this.name,
    required this.username,
    required this.email,
    required this.games,
    required this.following, // Pass the changed following list
    required this.followers, // Pass the changed followers list
    required this.profileUrl,
  });

  toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'username': username,
      'email': email,
      'following': following,
      'followers': followers,
      'games': games,
      'profilePicture': profileUrl
    };
  }

  factory FirebaseUserModel.fromMap(Map<dynamic, dynamic> data) {
    return FirebaseUserModel(
      uuid: data['uuid'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      following: data['following'] ?? {},
      followers: data['followers'] ?? {},
      games: data['games'] ?? {},
      profileUrl: data['profilePicture'] ?? '',
    );
  }

  factory FirebaseUserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> data) {
    final docData = data.data()!;
    return FirebaseUserModel(
      uuid: docData['id'] ?? '',
      name: docData['name'] ?? '',
      username: docData['username'] ?? '',
      email: docData['email'] ?? '',
      following: docData['following'] ?? {},
      followers: docData['followers'] ?? {},
      games: docData['games'] ?? {},
      profileUrl: docData['profilePicture'] ?? '',
    );
  }

  void update(GameModel model) {
    games[model.id] = model.toJson();
    notifyListeners();
  }

  void follow(FirebaseUserModel myModel, FirebaseUserModel otherModel, BuildContext context, Color color) {
    following[otherModel.uuid] = otherModel.uuid;
    otherModel.followers[myModel.uuid] = myModel.uuid;
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Followed ${otherModel.username}! 🫂",
      messageStyle: TextStyle(color: color.onColor),
      leading: GlassContainer(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          FontAwesomeIcons.solidHeart,
          color:
              Theme.of(context)
              .colorScheme
              .primary
        )
      )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

  void unfollow(FirebaseUserModel myModel, FirebaseUserModel otherModel, BuildContext context, Color color) {
    following.remove(otherModel.uuid);
    otherModel.followers.remove(myModel.uuid);
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Unfollowed ${otherModel.username}! 🤬",
      messageStyle: TextStyle(color: color.onColor),
      leading: GlassContainer(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
              FontAwesomeIcons.solidHeart,
              color:
              Theme.of(context)
                  .colorScheme
                  .onPrimary,
          )
      )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

}

