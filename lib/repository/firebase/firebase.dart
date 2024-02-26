import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../model/firebase/firebaseUser.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUserModel> getUserData() async {
    final userId = _auth.currentUser!.uid;
    final ref = FirebaseDatabase.instance.reference().child('users').child(userId);

    final snapshot = await ref.get();

    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;

      // Benutzerdaten aus Snapshot extrahieren
      String uuid = userId;
      String name = userData['name'] ?? '';
      String username = userData['username'] ?? '';
      String email = userData['email'] ?? '';
      String profileUrl = userData['profilePicture'] ?? '';
      List<GameModel> games = _parseGames(userData['games'] ?? {});
      FollowingModel following = _parseFollowing(userData['following'] ?? {});

      return FirebaseUserModel(
        uuid: uuid,
        name: name,
        username: username,
        email: email,
        games: games,
        following: following, profileUrl: profileUrl,
      );
    } else {
      throw Exception('Benutzerdaten nicht gefunden');
    }
  }

  List<GameModel> _parseGames(Map<dynamic, dynamic> gamesData) {
    List<GameModel> games = [];
    gamesData.forEach((key, value) {
      games.add(GameModel(
        id: key,
        wishlist: value['wishlist'] ?? false,
        recommended: value['recommended'] ?? false,
        rated: value['rated'] ?? false,
        rating: value['rating'] ?? 0.0,
      ));
    });
    return games;
  }

  FollowingModel _parseFollowing(Map<dynamic, dynamic> followingData) {
    String followingId = followingData['id'] ?? '';
    FirebaseUserModel followingUser = FirebaseUserModel(
      uuid: followingId,
      name: followingData['name'] ?? '',
      username: followingData['username'] ?? '',
      email: followingData['email'] ?? '',
      games: _parseGames(followingData['games'] ?? {}),
      following: _parseFollowing(followingData['following'] ?? {}), profileUrl: followingData['profilePicture'] ?? '',
    );
    return FollowingModel(id: followingId, firebaseUserModel: followingUser);
  }

}
