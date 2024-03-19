import 'package:carousel_slider/carousel_slider.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:profile_view/profile_view.dart';

import '../../repository/firebase/firebase.dart';
import '../firebase/firebaseUser.dart';
import '../igdb_models/game.dart';

class FollowingGameRatings extends StatefulWidget {
  final Game game;
  final Color color;

  const FollowingGameRatings({
    super.key,
    required this.game, required this.color,
  });

  @override
  _FollowingGameRatingsState createState() => _FollowingGameRatingsState();
}

class _FollowingGameRatingsState extends State<FollowingGameRatings>
    with SingleTickerProviderStateMixin {
  final getIt = GetIt.instance;
  List<FirebaseUserModel> followingRatedGame = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    Future.wait([_parseFollowers()]);
  }

  Future<void> _parseFollowers() async {
    final currentUser = getIt<FirebaseUserModel>();
    List<FirebaseUserModel> followers = [];
    for (var value in currentUser.following.values) {
      FirebaseUserModel firebaseUserModel =
          await FirebaseService().getSingleUserData(value);
      followers.add(firebaseUserModel);
    }

    List<FirebaseUserModel> filteredFollowers = followers
        .where((follower) =>
            follower.games.containsKey(widget.game.id.toString()) &&
            follower.games[widget.game.id.toString()]["rating"] > 0)
        .toList();
    setState(() {
      followingRatedGame = filteredFollowers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return followingRatedGame.isEmpty
        ? Container()
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                  height: 80,
                  autoPlayInterval: const Duration(seconds: 8),
                  autoPlayAnimationDuration:
                      const Duration(milliseconds: 1500),
                  autoPlay: true,
                  aspectRatio: 1,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.2,
                  enlargeFactor: .2),
              items: followingRatedGame.map((follower) {
                var rating = 0.0;
                for (var game in follower.games.entries) {
                  if (game.key == widget.game.id.toString()) {
                    rating = game.value["rating"] as double;
                    break;
                  }
                }
                return Builder(
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          GlassContainer(
                            height: 80,
                            width: 80,
                            blur: 12,
                            shadowStrength: 1.7,
                            color: widget.color.darken(10).withOpacity(.7),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(14),
                            shadowColor: widget.color.darken(30),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ProfileView(
                                  image: NetworkImage(follower.profileUrl),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GlassContainer(
                              blur: 12,
                              shadowStrength: 4,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(14),
                              shadowColor: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 4),
                                child: CircularRatingWidget(
                                  ratingValue: rating * 10,
                                  radiusMultiplicator: .03,
                                  fontSize: 8,
                                  lineWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        );
  }
}
