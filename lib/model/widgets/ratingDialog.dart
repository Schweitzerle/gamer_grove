import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/topThreeUserGamesWidget.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:like_button/like_button.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
import '../firebase/firebaseUser.dart';
import '../igdb_models/game.dart';

class CustomRatingDialog extends StatefulWidget {
  final Color colorPalette;
  final Color adjustedTextColor;
  final Game game;

  const CustomRatingDialog({super.key,
    required this.colorPalette,
    required this.adjustedTextColor,
    required this.game,
  });

  @override
  _CustomRatingDialogState createState() => _CustomRatingDialogState();
}

class _CustomRatingDialogState extends State<CustomRatingDialog>
    with TickerProviderStateMixin {
  final getIt = GetIt.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 400,
      child: contentBox(context),
    );
  }
  contentBox(context) {
    return StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: <Widget>[
              GlassContainer(
                shadowColor: widget.colorPalette.lighten(20),
                shadowStrength: 8,
                blur: 2,
                color: Theme
                    .of(context)
                    .colorScheme
                    .background,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: GlassContainer(
                          width: double.infinity,
                          blur: 12,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .background,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: widget.colorPalette.darken(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FittedBox(
                              child: Text(
                                '${widget.game.name}',
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14,),
                      TopThreeUserGamesWidget(game: widget.game,),
                      const SizedBox(
                        height: 14,
                      ),
                      StaggeredGrid.count(
                          crossAxisCount: 12,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 8,
                          children: [
                            StaggeredGridTile.count(
                              crossAxisCellCount: 6,
                              mainAxisCellCount: 3,
                              child: GlassContainer(
                                blur: 12,
                                shadowStrength: 4,
                                color: Colors.blue.lighten(20).withOpacity(.8),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(14),
                                shadowColor: Colors.blue.lighten(20),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: [
                                      LikeButton(
                                        onTap: (isWishlist) async {
                                          HapticFeedback.selectionClick();
                                          await _updateGameWishlistStatusInDatabase();
                                          return !isWishlist; // Return the updated isLiked value
                                        },
                                        isLiked: widget.game.gameModel.wishlist,
                                        circleColor: const CircleColor(
                                            start: Colors.blueAccent,
                                            end: Colors.lightBlueAccent),
                                        bubblesColor: const BubblesColor(
                                            dotPrimaryColor: Colors.blue,
                                            dotSecondaryColor: Colors
                                                .lightBlue),
                                        likeBuilder: (isRecommended) {
                                          return Icon(
                                            FontAwesomeIcons.solidBookmark,
                                            color: isRecommended
                                                ? Colors.blueAccent
                                                : Colors.white,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Wishlist',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 6,
                              mainAxisCellCount: 3,
                              child: GlassContainer(
                                blur: 12,
                                shadowStrength: 4,
                                shape: BoxShape.rectangle,
                                color: Colors.orange.lighten(20).withOpacity(
                                    .8),
                                borderRadius: BorderRadius.circular(14),
                                shadowColor: Colors.orange,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: [
                                      LikeButton(
                                        onTap: (isRecommended) async {
                                          HapticFeedback.selectionClick();
                                          await _updateGameRecommendStatusInDatabase();
                                          return !isRecommended; // Return the updated isLiked value
                                        },
                                        isLiked: widget.game.gameModel.recommended,
                                        circleColor: const CircleColor(
                                            start: Colors.deepOrangeAccent,
                                            end: Colors.orangeAccent),
                                        bubblesColor: const BubblesColor(
                                            dotPrimaryColor: Colors.deepOrange,
                                            dotSecondaryColor: Colors.orange),
                                        likeBuilder: (isRecommended) {
                                          return Icon(
                                            FontAwesomeIcons.thumbsUp,
                                            color: isRecommended
                                                ? Colors.deepOrange
                                                : Colors.white,
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                        'Recommend',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 4,
                              mainAxisCellCount: 3,
                              child: GlassContainer(
                                blur: 12,
                                shadowStrength: 4,
                                shape: BoxShape.rectangle,
                                color: Colors.black.lighten(20).withOpacity(.8),
                                borderRadius: BorderRadius.circular(14),
                                shadowColor: Colors.black,
                                child: TextButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.of(context).pop();
                                  },
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      children: [
                                        Icon(
                                          CupertinoIcons.arrow_uturn_left,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 4,
                              mainAxisCellCount: 3,
                              child: GlassContainer(
                                blur: 12,
                                shadowStrength: 4,
                                shape: BoxShape.rectangle,
                                color: Colors.red.lighten(20).withOpacity(.8),
                                borderRadius: BorderRadius.circular(14),
                                shadowColor: Colors.red,
                                child: TextButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    _deleteGameStatusInDatabase();
                                  },
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      children: [
                                        Icon(
                                          CupertinoIcons.delete,
                                          color: Colors.red,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Delete Rating',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 4,
                              mainAxisCellCount: 3,
                              child: GlassContainer(
                                blur: 12,
                                shadowStrength: 4,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.green.lighten(20).withOpacity(.8),
                                shadowColor: Colors.green,
                                child: TextButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    _updateRatingInDatabase();
                                    Navigator.of(context).pop();
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      children: [
                                        Icon(
                                          CupertinoIcons.gamecontroller_fill,
                                          color: Colors.green.darken(20),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Text(
                                          'Save Rating',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(
                        height: 14,
                      ),
                      Center(
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: widget.colorPalette.darken(30),
                          color: widget.adjustedTextColor,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RatingBar.builder(
                                itemSize: 42,
                                initialRating: widget.game.gameModel.rating
                                    .toDouble() == 0 ? .5 : widget.game.gameModel
                                    .rating.toDouble(),
                                minRating: .5,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                glowRadius: 1,
                                glowColor: widget.colorPalette.lighten(20),
                                glow: true,
                                unratedColor: widget.adjustedTextColor ==
                                    Colors.white
                                    ? widget.colorPalette.lighten(40)
                                    : widget.colorPalette.darken(40),
                                itemCount: 10,
                                itemPadding: const EdgeInsets.symmetric(
                                    horizontal: 1.5),
                                itemBuilder: (context, _) =>
                                    Icon(
                                      CupertinoIcons.gamecontroller_fill,
                                      color: widget.adjustedTextColor ==
                                          Colors.white
                                          ? widget.colorPalette.darken(40)
                                          : widget.colorPalette.lighten(40),
                                    ),
                                onRatingUpdate: (updatedRating) {
                                  widget.game.gameModel.rating = updatedRating;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
    );
  }


  Future<void> _updateRatingInDatabase() async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    widget.game.gameModel.updateRating(context, widget.colorPalette, widget.game);
    currentUser.updateGames(widget.game.gameModel);
    await userDoc.update({'games': currentUser.games});
  }

  Future<void> _deleteGameStatusInDatabase() async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    widget.game.gameModel.deleteRating(context, widget.colorPalette, widget.game);
    currentUser.updateGames(widget.game.gameModel);
    await userDoc.update({'games': currentUser.games});
  }

  Future<void> _updateGameRecommendStatusInDatabase() async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    widget.game.gameModel.updateRecommended(context, widget.colorPalette, widget.game);
    currentUser.updateGames(widget.game.gameModel);
    await userDoc.update({'games': currentUser.games});
  }

  Future<void> _updateGameWishlistStatusInDatabase() async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    widget.game.gameModel.updateWishlist(context, widget.colorPalette, widget.game);
    currentUser.updateGames(widget.game.gameModel);
    await userDoc.update({'games': currentUser.games});
  }
}
