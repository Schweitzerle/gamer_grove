import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

import '../igdb_models/game.dart';

class GameModel extends ChangeNotifier {
  final String id;
  bool wishlist;
  bool recommended;
  num rating;

  GameModel({
    required this.id,
    required this.wishlist,
    required this.recommended,
    required this.rating,
  });

  toJson() {
    return {
      'id': id,
      'rating': rating,
      'recommended': recommended,
      'wishlist': wishlist,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> data) {
    return GameModel(
      id: data['id'],
      rating: data['rating'] ?? 0.0,
      recommended: data['recommended'] ?? false,
      wishlist: data['wishlist'] ?? false,
    );
  }

  factory GameModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> data) {
    final docData = data.data()!;
    return GameModel(
      id: docData['id'],
      rating: docData['rating'] ?? 0.0,
      recommended: docData['recommended'] ?? false,
      wishlist: docData['wishlist'] ?? false,
    );
  }

  void updateRecommended(BuildContext context, Color color, Game game) {
    recommended = !recommended;
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "${recommended ? 'Recommended' : 'Unrecommended'} ${game.name}! ${recommended ? '🤩' : '😒'}",
      messageStyle: TextStyle(color: color.onColor),
      leading: GlassContainer(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(FontAwesomeIcons.thumbsUp, color: recommended ? Colors.deepOrange : Colors.white,),
      )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

  void updateWishlist(BuildContext context, Color color, Game game) {
    wishlist = !wishlist;
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "${wishlist ? 'Added to Wishlist:' : 'Removed from Wishlist:'} ${game.name}! ${wishlist ? '🧐' : '😴'}",
      messageStyle: TextStyle(color: color.onColor),
      leading: GlassContainer(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(FontAwesomeIcons.solidBookmark, color: wishlist ? Colors.blueAccent : Colors.white,),
      )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

  void updateRating(BuildContext context, Color color, Game game) {
    rating = rating;
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Rated ${game.name} with ${rating * 10}! 😎",
      messageStyle: TextStyle(color: color.onColor),
      leading: GlassContainer(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularRatingWidget(ratingValue: rating * 10, radiusMultiplicator: .04,
          fontSize: 10,
          lineWidth: 3,),
      )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }

  void deleteRating(BuildContext context, Color color, Game game) {
    rating = 0;
    ToastService.showToast(
      context,
      isClosable: true,
      backgroundColor: color,
      shadowColor: color.darken(20),
      length: ToastLength.medium,
      expandedHeight: 100,
      message: "Deleted Rating for ${game.name}! 😵‍💫",
      messageStyle: TextStyle(color: color.onColor),
      leading: const GlassContainer(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(CupertinoIcons.delete, color: Colors.redAccent,),
      )),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
    notifyListeners();
  }
}
