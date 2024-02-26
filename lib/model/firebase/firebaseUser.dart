class FirebaseUserModel {
  final String uuid;
  final String name;
  final String username;
  final String email;
  final List<GameModel> games;
  final FollowingModel? following;
  final String profileUrl;

  FirebaseUserModel({
    required this.uuid,
    required this.name,
    required this.username,
    required this.email,
    required this.games,
    this.following,
    required this.profileUrl,
  });
}

class GameModel {
  final String id;
  final bool wishlist;
  final bool recommended;
  final bool rated;
  final double rating;

  GameModel({
    required this.id,
    required this.wishlist,
    required this.recommended,
    required this.rated,
    required this.rating,
  });
}

class FollowingModel {
  final String id;
  final FirebaseUserModel firebaseUserModel;

  FollowingModel({
    required this.id,
    required this.firebaseUserModel,
  });
}
