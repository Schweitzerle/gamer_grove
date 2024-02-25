
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

import '../../model/igdb_models/game.dart';
import '../../model/igdb_models/game_mode.dart';
import '../../model/igdb_models/genre.dart';
import '../../model/igdb_models/platform.dart';
import '../../model/igdb_models/player_perspectiverequest_path.dart';
import '../../model/igdb_models/theme.dart';
import '../../model/singleton/sinlgleton.dart';
import '../../model/widgets/game_filter_widget.dart';
import '../searchScreen/search_screen.dart';

class FriendsScreen extends StatefulWidget {

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container()
    );
  }

}