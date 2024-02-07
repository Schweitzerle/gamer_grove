
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/singleton/sinlgleton.dart';

class FriendsScreen extends StatefulWidget {

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*PappBar: AppBar(
      title: Text('Follower'),
      automaticallyImplyLeading: false,
      backgroundColor: Singleton.secondTabColor,
      actions: [
        //TODO: IGDB Logo
        adding(
            padding: EdgeInsets.all(5),
            child: SvgPicture.asset(
              "assets/images/tmdb_logo.svg",
              fit: BoxFit.fitHeight, //
              alignment:
              Alignment.centerRight, // Adjust the fit property as needed
            ),
          ),
      ],
    ),*/
    );
  }

}