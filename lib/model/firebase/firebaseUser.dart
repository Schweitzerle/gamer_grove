import 'package:auth_service/auth.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/repository/firebase/firebase.dart';
import 'package:get_it/get_it.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:profile_view/profile_view.dart';

class FirebaseUserModel {
  final String uuid;
  final String name;
  final String username;
  final String email;
  final List<GameModel> games;
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
      games: _parseGames(data['games'] ?? []),
      profileUrl: data['profilePicture'] ?? '',
    );
  }

  factory FirebaseUserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> data) {
    final docData = data.data()!;
    return FirebaseUserModel(
      uuid: docData['id'] ?? '',
      name: docData['name'] ?? '',
      username: docData['username'] ?? '',
      email: docData['email'] ?? '',
      following: docData['following'] ?? {},
      followers: docData['followers'] ?? {},
      games: _parseGames(docData['games'] ?? []),
      profileUrl: docData['profilePicture'] ?? '',
    );
  }


  static List<GameModel> _parseGames(List<dynamic> gamesData) {
    List<GameModel> games = [];
    for (var value in gamesData) {
      games.add(GameModel(
        id: value['gameID'],
        wishlist: value['wishlist'] ?? false,
        recommended: value['recommended'] ?? false,
        rated: value['rated'] ?? false,
        rating: value['rating'] ?? 0.0,
      ));
    }
    return games;
  }

  static Future<List<FirebaseUserModel>> _parseFollowers(
      Map<dynamic, dynamic> gamesData) async {
    List<FirebaseUserModel> games = [];
    for (var value in gamesData.values) {
      FirebaseUserModel firebaseUserModel =
          await FirebaseService().getSingleUserData(value);
      games.add(firebaseUserModel);
    }
    return games;
  }
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

class UserListItem extends StatefulWidget {
  final FirebaseUserModel user;
  final BuildContext buildContext;

  const UserListItem({Key? key, required this.user, required this.buildContext})
      : super(key: key);

  @override
  _UserListItemState createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  late Future<Color> colorpaletteFuture;
  late Color textColor;
  late bool isFollowing = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final getIt = GetIt.instance;


  @override
  void initState() {
    super.initState();
    colorpaletteFuture = getColorPalette();
  }

  Future<bool> isFollowingUser() async {
    final currentUser = getIt<FirebaseUserModel>();
    return currentUser.following.containsValue(widget.user.uuid);
  }

  Future<Color> getColorPalette() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.user.profileUrl),
      size: Size(100, 150),
      maximumColorCount: 10,
    );
    final color = paletteGenerator.dominantColor?.color ??
        Theme.of(context).colorScheme.inversePrimary;
    final luminance = color.computeLuminance();
    final targetLuminance = 0.5;
    textColor = luminance > targetLuminance ? Colors.black : Colors.white;
    isFollowing = await isFollowingUser();
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color>(
        future: colorpaletteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClayContainer(
                width: double.infinity,
                // Occupy full width
                height: 80,
                spread: 2,
                depth: 60,
                color: Theme.of(context).colorScheme.inversePrimary,
                borderRadius: 14,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LoadingIndicator(
                      indicatorType: Indicator.pacman,

                      /// Required, The loading type of the widget
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            throw snapshot.error!;
          } else {
            final colorpalette = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClayContainer(
                width: double.infinity,
                // Occupy full width
                height: 80,
                color: colorpalette,
                spread: 2,
                depth: 60,
                borderRadius: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // Move games count to the right
                  children: [
                    // Profile picture
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProfileView(
                        image: NetworkImage(widget.user.profileUrl),
                      ),
                    ),
                    // User information
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor),
                          ),
                          Text(
                            '@${widget.user.username}',
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ],
                      ),
                    ),
                    // Games count
                    const SizedBox(width: 16), // Add some right padding
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // Move games count to the right
                        children: [
                          Text(
                            '${widget.user.games.length} Games',
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                          LikeButton(
                            onTap: (isFollowing) async {
                              await _updateFollowStatusInDatabase(!isFollowing);
                              return !isFollowing; // Return the updated isLiked value
                            },
                            isLiked: isFollowing,
                            circleColor: CircleColor(
                                start: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                end: Theme.of(context).colorScheme.secondary),
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              dotSecondaryColor: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                            ),
                            likeBuilder: (isFollowing) {
                              return Icon(
                                FontAwesomeIcons.solidHeart,
                                color: isFollowing
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onPrimary,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16), // Add some right padding
                  ],
                ),
              ),
            );
          }
        });
  }

  Future<void> _updateFollowStatusInDatabase(bool isFollowing) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userFollowsDoc = FirebaseFirestore.instance.collection('Users').doc(widget.user.uuid);

    if (isFollowing) {
      currentUser.following[widget.user.uuid] = widget.user.uuid; // Update local following map
      await userDoc.update({'following': currentUser.following}); // Update following map in user doc
      widget.user.followers[currentUser.uuid] = currentUser.uuid; // Update local following map
      await userFollowsDoc.update({'followers': widget.user.followers}); // Update following map in user doc
    } else {
      currentUser.following.remove(widget.user.uuid); // Remove from local following map
      await userDoc.update({'following': currentUser.following}); // Update following map in user doc
      widget.user.followers.remove(currentUser.uuid); // Update local following map
      await userFollowsDoc.update({'followers': widget.user.followers}); // Update following map in user doc
    }
  }

}
