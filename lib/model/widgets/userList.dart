import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/userListItem.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../firebase/firebaseUser.dart';
import '../igdb_models/game.dart';
import '../views/gameGridPaginationView.dart';
import '../views/gameGridView.dart';

class UserListView extends StatefulWidget {
  final List<FirebaseUserModel>? games;
  final int showLimit;
  final bool isFollowing;

  UserListView({
    required this.games,
    required this.showLimit, required this.isFollowing,
  });

  @override
  State<StatefulWidget> createState() => UserListViewState();
}

class UserListViewState extends State<UserListView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;

    return widget.games != null && widget.games!.isNotEmpty
        ? Padding(
          padding: EdgeInsets.only(top: widget.isFollowing ? 60.0 : 0),
          child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.games!.length < widget.showLimit
                  ? widget.games!.length
                  : widget.showLimit,
              itemBuilder: (context, index) {
                if (index >= widget.games!.length) {
                  return null; // or a placeholder widget
                }
                final user = widget.games![index];
                return UserListItem(
                  user: user,
                  buildContext: context,
                );
              }),
        )
        :Container();
  }
}
