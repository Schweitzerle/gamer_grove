import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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

  void updateRecommended() {
    recommended = !recommended;
    notifyListeners();
  }

  void updateWishlist() {
    wishlist = !wishlist;
    notifyListeners();
  }

  void updateRating() {
    rating = rating;
    notifyListeners();
  }

  void deleteRating() {
    rating = 0;
    notifyListeners();
  }
}
