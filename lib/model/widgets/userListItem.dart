import 'package:clay_containers/widgets/clay_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/shimmerGameItem.dart';
import 'package:get_it/get_it.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:profile_view/profile_view.dart';
import 'package:provider/provider.dart';

import '../firebase/firebaseUser.dart';
import '../views/otherUserProfileView.dart';

class UserListItem extends StatefulWidget {
  final FirebaseUserModel user;
  final BuildContext buildContext;

  const UserListItem({Key? key, required this.user, required this.buildContext})
      : super(key: key);

  @override
  _UserListItemState createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  late Color textColor;
  late bool isFollowing = false;
  final getIt = GetIt.instance;
  late Color colorPalette;
  bool isColorLoaded = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      textColor = Theme.of(widget.buildContext).colorScheme.onTertiaryContainer;
      colorPalette =
          Theme.of(widget.buildContext).colorScheme.tertiaryContainer;
    });
    await Future.wait([getColorPalette()]);
  }

  bool isFollowingUser(FirebaseUserModel currentUser) {
    return currentUser.following.containsValue(widget.user.uuid);
  }

  Future<void> getColorPalette() async {
    if (widget.user.profileUrl.isNotEmpty) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.user.profileUrl),
        maximumColorCount: 10,
      );
      setState(() {
        colorPalette = paletteGenerator.dominantColor?.color ??
            Theme.of(widget.buildContext).colorScheme.tertiaryContainer;
        textColor = colorPalette.onColor;
        isColorLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt<FirebaseUserModel>();
    return ChangeNotifierProvider.value(
        value: currentUser,
        child: Consumer<FirebaseUserModel>(
            builder: (context, currentUserConsumer, child) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(
                        userModel: widget.user,
                        colorPalette: colorPalette.darken(10),
                      )));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isColorLoaded
                  ? ClayContainer(
                      width: double.infinity,
                      height: 80,
                      color: colorPalette.darken(10),
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
                                  style:
                                      TextStyle(fontSize: 14, color: textColor),
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
                                  style:
                                      TextStyle(color: textColor, fontSize: 12),
                                ),
                                LikeButton(
                                  onTap: (isFollowing) async {
                                    await _updateFollowStatusInDatabase(
                                        !isFollowing);
                                    setState(() {});
                                    return !isFollowing; // Return the updated isLiked value
                                  },
                                  isLiked: isFollowingUser(currentUserConsumer),
                                  circleColor: CircleColor(
                                      start: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      end: Theme.of(context)
                                          .colorScheme
                                          .secondary),
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
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16), // Add some right padding
                        ],
                      ))
                  : const ShimmerUserItem()
            ),
          );
        }));
  }

  Future<void> _updateFollowStatusInDatabase(bool isFollowing) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userDoc =
        FirebaseFirestore.instance.collection('Users').doc(currentUser.uuid);
    final userFollowsDoc =
        FirebaseFirestore.instance.collection('Users').doc(widget.user.uuid);

    if (isFollowing) {
      currentUser.follow(currentUser, widget.user, context, colorPalette);
      await userDoc.update({'following': currentUser.following});
      await userFollowsDoc.update({'followers': widget.user.followers});
    } else {
      currentUser.unfollow(currentUser, widget.user, context, colorPalette);
      await userDoc.update({'following': currentUser.following});
      await userFollowsDoc.update({'followers': widget.user.followers});
    }
  }
}
