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

import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import 'gameModel.dart';

class FirebaseUserModel extends ChangeNotifier {
  final String id;
  final String name;
  final String username;
  final String email;
  Map<String, dynamic> games;
  Map<String, dynamic> firstTopGame;
  Map<String, dynamic> secondTopGame;
  Map<String, dynamic> thirdTopGame;
  final Map<dynamic, dynamic> following; // Change type to List<String>
  final Map<dynamic, dynamic> followers; // Change type to List<String>
  final String profileUrl;

  FirebaseUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.games,
    required this.firstTopGame,
    required this.secondTopGame,
    required this.thirdTopGame,
    required this.following, // Pass the changed following list
    required this.followers, // Pass the changed followers list
    required this.profileUrl,
  });

  toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'following': following,
      'followers': followers,
      'games': games,
      'firstTopGame': firstTopGame,
      'secondTopGame': secondTopGame,
      'thirdTopGame': thirdTopGame,
      'profilePicture': profileUrl
    };
  }

  factory FirebaseUserModel.fromMap(Map<dynamic, dynamic> data) {
    return FirebaseUserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      following: data['following'] ?? {},
      followers: data['followers'] ?? {},
      games: data['games'] ?? {},
      firstTopGame: data['firstTopGame'] ?? {},
      secondTopGame: data['secondTopGame'] ?? {},
      thirdTopGame: data['thirdTopGame'] ?? {},
      profileUrl: data['profilePicture'] ?? '',
    );
  }

  factory FirebaseUserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> data) {
    final docData = data.data()!;
    return FirebaseUserModel(
      id: docData['id'] ?? '',
      name: docData['name'] ?? '',
      username: docData['username'] ?? '',
      email: docData['email'] ?? '',
      following: docData['following'] ?? {},
      followers: docData['followers'] ?? {},
      games: docData['games'] ?? {},
      firstTopGame: docData['firstTopGame'] ?? {},
      secondTopGame: docData['secondTopGame'] ?? {},
      thirdTopGame: docData['thirdTopGame'] ?? {},
      profileUrl: docData['profilePicture'] ?? '',
    );
  }

  void updateGames(GameModel model) {
    games[model.id] = model.toJson();
    notifyListeners();
  }

  Future<void> updateFirstTopGame(GameModel model, BuildContext context, Color color, Game game) async {
    final getIt = GetIt.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    const bottomColor = Color(0xFF87868c);
    const middleColor = Color(0xFFA48111);
    firstTopGame.clear();
    firstTopGame[model.id] = model.toJson();
    if (secondTopGame.containsKey(game.id.toString())) {
      deleteSecondTopGame(context, middleColor, game);
      await userDoc.update({'secondTopGame': currentUser.secondTopGame});
    }
    if (thirdTopGame.containsKey(game.id.toString())) {
      deleteThirdTopGame(context, bottomColor, game);
      await userDoc.update({'thirdTopGame': currentUser.thirdTopGame});
    }
    Future.delayed(const Duration(seconds: 2), () {
      ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Set ${game.name} as Top Game! 🤩",
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
    });
    notifyListeners();
  }

  void deleteFirstTopGame(BuildContext context, Color color, Game game) {
    firstTopGame.clear();
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Removed ${game.name} as Top Game! 🙄",
      messageStyle: TextStyle(color: color.onColor),
      leading: const GlassContainer(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(CupertinoIcons.delete, color: Colors.red),
          )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

  Future<void> updateSecondTopGame(GameModel model, BuildContext context, Color color, Game game) async {
    final getIt = GetIt.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    const bottomColor = Color(0xFF87868c);
    const topColor = Color(0xFF6B0000);
    secondTopGame.clear();
    secondTopGame[model.id] = model.toJson();
    if (firstTopGame.containsKey(game.id.toString())) {
      deleteFirstTopGame(context, topColor, game);
      await userDoc.update({'firstTopGame': currentUser.firstTopGame});
    }
    if (thirdTopGame.containsKey(game.id.toString())) {
      deleteThirdTopGame(context, bottomColor, game);
      await userDoc.update({'thirdTopGame': currentUser.thirdTopGame});
    }
    Future.delayed(const Duration(seconds: 2), () {
      ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Set ${game.name} in Top Two Games! 😍",
      messageStyle: TextStyle(color: color.onColor),
      leading: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('2.', style: TextStyle(color: color.onColor, fontWeight: FontWeight.bold),),
          )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    });
    notifyListeners();
  }

  void deleteSecondTopGame(BuildContext context, Color color, Game game) {
    secondTopGame.clear();
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Removed ${game.name} from Top Two Games! 🙄",
      messageStyle: TextStyle(color: color.onColor),
      leading: const GlassContainer(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(CupertinoIcons.delete, color: Colors.red),
          )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

  Future<void> updateThirdTopGame(GameModel model, BuildContext context, Color color, Game game) async {
    final getIt = GetIt.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    const middleColor = Color(0xFFA48111);
    const topColor = Color(0xFF6B0000);
    thirdTopGame.clear();
    thirdTopGame[model.id] = model.toJson();
    if (secondTopGame.containsKey(game.id.toString())) {
      deleteSecondTopGame(context, middleColor, game);
      await userDoc.update({'secondTopGame': currentUser.secondTopGame});
    }
    if (firstTopGame.containsKey(game.id.toString())) {
      deleteFirstTopGame(context, topColor, game);
      await userDoc.update({'firstTopGame': currentUser.firstTopGame});
    }
    Future.delayed(const Duration(seconds: 2), () {
      ToastService.showToast(
        context,
        isClosable: true,
        backgroundColor: color,
        shadowColor: color.darken(20),
        length: ToastLength.medium,
        expandedHeight: 100,
        message: "Set ${game.name} in Top Three Games! 😊",
        messageStyle: TextStyle(color: color.onColor),
        leading: GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('3.', style: TextStyle(color: color.onColor, fontWeight: FontWeight.bold),),
            )),
        slideCurve: Curves.elasticInOut,
        positionCurve: Curves.bounceOut,
        dismissDirection: DismissDirection.none,
      );
    });

    notifyListeners();
  }

  void deleteThirdTopGame(BuildContext context, Color color, Game game) {
    thirdTopGame.clear();
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Removed ${game.name} from Top Three Games! 🙄",
      messageStyle: TextStyle(color: color.onColor),
      leading: const GlassContainer(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(CupertinoIcons.delete, color: Colors.red),
          )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

  void follow(FirebaseUserModel myModel, FirebaseUserModel otherModel, BuildContext context, Color color) {
    following[otherModel.id] = otherModel.id;
    otherModel.followers[myModel.id] = myModel.id;
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
    following.remove(otherModel.id);
    otherModel.followers.remove(myModel.id);
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

