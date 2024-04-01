import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

import '../../model/firebase/firebaseUser.dart';
import '../../model/igdb_models/game.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;


  Future<FirebaseUserModel> getSingleCurrentUserData() async {
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final snapshot = await _db.collection('Users').where('id', isEqualTo: userId).get();
    final data = snapshot.docs.map((e) => FirebaseUserModel.fromSnapshot(e)).single;
    data.games.removeWhere((key, value) {
      return !value['recommended'] && !value['wishlist'] && value['rating'] == 0;
    });
    await userDoc.update({'games': data.games});
    return data;
  }

  Future<FirebaseUserModel> getSingleUserData(String userId) async {
    final snapshot = await _db.collection('Users').where('id', isEqualTo: userId).get();
    final data = snapshot.docs.map((e) => FirebaseUserModel.fromSnapshot(e)).single;
    return data;
  }

  Future<List<FirebaseUserModel>> getFollowingUserData(Map<dynamic, dynamic> following) async {
    final followingUserIDs = following.keys.toList();
    if (followingUserIDs.isNotEmpty) {
      final snapshots = await _db.collection('Users').where('id', whereIn: followingUserIDs).get();
      // Use map instead of for loop for more concise data conversion
      final followingUsers = snapshots.docs.map((e) => FirebaseUserModel.fromSnapshot(e)).toList();
      return followingUsers;
    }
   return [];
  }


  Future<List<FirebaseUserModel>> getAllUserData() async {
    final snapshot = await _db.collection('Users').get();
    if (snapshot.size > 0) {
      final data = snapshot.docs.map((e) => FirebaseUserModel.fromSnapshot(e)).toList();
      return data;
    }
    return [];
  }

  Future<List<FirebaseUserModel>> getAllUsers() async {
    final userId = _auth.currentUser!.uid;
    final usersRef = FirebaseDatabase.instance.ref().child('Users');
    List<FirebaseUserModel> allUsers = [];

    final snapshot = await usersRef.get();

    if (snapshot.exists) {
      final userMaps = snapshot.value as  Map<dynamic, dynamic>;

      for (final value in userMaps.values) {
        FirebaseUserModel userModel = FirebaseUserModel.fromMap(value);
        if(userModel.uuid != userId) {
          allUsers.add(userModel);
        }
    }
      return allUsers;
    } else {
      print('No data available.');
      return allUsers;
    }
  }


  Future<List<FirebaseUserModel>> getUsersByQuery(String query) async {
    final userId = _auth.currentUser!.uid;
    final usersRef = await getAllUserData();
    List<FirebaseUserModel> matchingUsers = [];

    for (FirebaseUserModel user in usersRef) {
      if (user.name.toLowerCase().contains(query.toLowerCase()) || user.username.toLowerCase().contains(query.toLowerCase())) {
        if(user.uuid != userId) {
          matchingUsers.add(user);
        }
      }
    }

    return matchingUsers;
  }


  Future<List<FirebaseUserModel>> getFollowers() async {
    final userId = _auth.currentUser!.uid;
    final usersRef = FirebaseDatabase.instance.ref().child('users').child(userId).child('followers');
    List<FirebaseUserModel> allUsers = [];

    final snapshot = await usersRef.get();

    if (snapshot.exists) {
      final userMaps = snapshot.value as  Map<dynamic, dynamic>;

      for (final value in userMaps.values) {
        FirebaseUserModel userModel = FirebaseUserModel.fromMap(value);
        allUsers.add(userModel);
      }
      return allUsers;
    } else {
      print('No data available.');
      return allUsers;
    }

  }
}



