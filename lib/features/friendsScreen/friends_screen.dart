import 'package:clay_containers/widgets/clay_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gamer_grove/model/widgets/shimmerGameItem.dart';
import 'package:gamer_grove/model/widgets/userList.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:profile_view/profile_view.dart';
import 'package:provider/provider.dart';
import 'package:vitality/vitality.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

import '../../model/firebase/firebaseUser.dart';
import '../../model/igdb_models/game.dart';
import '../../model/igdb_models/game_mode.dart';
import '../../model/igdb_models/genre.dart';
import '../../model/igdb_models/platform.dart';
import '../../model/igdb_models/player_perspectiverequest_path.dart';
import '../../model/igdb_models/theme.dart';
import '../../model/singleton/sinlgleton.dart';
import '../../model/widgets/game_filter_widget.dart';
import '../../model/widgets/userListItem.dart';
import '../../repository/firebase/firebase.dart';
import '../searchScreen/search_screen.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late FloatingSearchBarController _searchBarController;
  late ScrollController _scrollController;
  String query = "";
  final getIt = GetIt.instance;
  List<FirebaseUserModel> userFollowing = [];
  List<FirebaseUserModel> allFetchedUsers = [];
  List<FirebaseUserModel> queryUsers = [];

  @override
  void initState() {
    super.initState();
    Future.wait([_parseUsers()]);
    _searchBarController = FloatingSearchBarController();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          _searchBarController.show();
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _searchBarController.hide();
        }
      }
    });
  }

  Future<void> _parseUsers() async {
    final currentUser = getIt<FirebaseUserModel>();
    final allUsers = await FirebaseService().getAllUserData();
    setState(() {
      allUsers.removeWhere((element) => element.id == currentUser.id);
      allUsers.shuffle();
      allFetchedUsers = allUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    Color color = Theme.of(context).colorScheme.inversePrimary.darken(20);
    final currentUser = getIt<FirebaseUserModel>();
    return Scaffold(
      body: Stack(children: [
        Vitality.randomly(
          background: Theme.of(context).colorScheme.background,
          maxOpacity: 0.8,
          minOpacity: 0.3,
          itemsCount: 80,
          enableXMovements: false,
          whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
          maxSpeed: 0.1,
          maxSize: 30,
          minSpeed: 0.1,
          randomItemsColors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.onPrimary
          ],
          randomItemsBehaviours: [
            ItemBehaviour(
                shape: ShapeType.Icon, icon: CupertinoIcons.person_add),
            ItemBehaviour(
                shape: ShapeType.Icon, icon: CupertinoIcons.person_add_solid),
            ItemBehaviour(
                shape: ShapeType.Icon,
                icon: CupertinoIcons.rectangle_stack_person_crop_fill),
            ItemBehaviour(
                shape: ShapeType.Icon,
                icon: CupertinoIcons.rectangle_stack_person_crop),
            ItemBehaviour(
                shape: ShapeType.Icon, icon: CupertinoIcons.group_solid),
            ItemBehaviour(shape: ShapeType.Icon, icon: CupertinoIcons.group),
            ItemBehaviour(shape: ShapeType.StrokeCircle),
          ],
        ),
        ChangeNotifierProvider.value(
          value: currentUser,
          child: Consumer<FirebaseUserModel>(
              builder: (context, firebaseUserModel, child) {
            return FutureBuilder<List<FirebaseUserModel>>(
                future: FirebaseService()
                    .getFollowingUserData(firebaseUserModel.following),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<FirebaseUserModel> following = snapshot.data!;
                    return Stack(children: [
                      UserListView(
                        games: following,
                        showLimit: following.length,
                        isFollowing: true,
                      ),
                      FloatingSearchBar(
                        showCursor: true,
                        elevation: 20,
                        borderRadius: BorderRadius.circular(14),
                        border: BorderSide(
                            color: Theme.of(context).colorScheme.background),
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        shadowColor: Theme.of(context).shadowColor,
                        iconColor: Theme.of(context)
                            .bottomNavigationBarTheme
                            .selectedItemColor,
                        accentColor: Theme.of(context)
                            .bottomNavigationBarTheme
                            .selectedItemColor,
                        backdropColor: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(.7),
                        controller: _searchBarController,
                        hint: 'Search for Users',
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              query = value;
                              final filteredUsers = allFetchedUsers.where((user) {
                                final username = user.username.toLowerCase();
                                final name = user.name.toLowerCase();
                                return username.contains(query.toLowerCase()) || name.contains(query.toLowerCase());
                              }).toList();
                              queryUsers = filteredUsers;
                            });
                          }
                        },
                        scrollPadding:
                            const EdgeInsets.only(top: 16, bottom: 56),
                        transitionDuration: const Duration(milliseconds: 800),
                        transitionCurve: Curves.easeInOut,
                        physics: const BouncingScrollPhysics(),
                        axisAlignment: true ? 0.0 : -1.0,
                        openAxisAlignment: 0.0,
                        width: true ? 600 : 500,
                        debounceDelay: const Duration(milliseconds: 500),
                        onQueryChanged: (value) {
                          setState(() {
                            query = value;
                            final filteredUsers = allFetchedUsers.where((user) {
                              final username = user.username.toLowerCase();
                              final name = user.name.toLowerCase();
                              return username.contains(query.toLowerCase()) || name.contains(query.toLowerCase());
                            }).toList();
                            queryUsers = filteredUsers;
                          });
                        },
                        transition: CircularFloatingSearchBarTransition(),
                        actions: [
                          FloatingSearchBarAction(
                            showIfOpened: false,
                            child: CircularButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                }),
                          ),
                          FloatingSearchBarAction.searchToClear(
                            showIfClosed: false,
                          ),
                        ],
                        clearQueryOnClose: false,
                        builder: (context, transition) {
                          return ClayContainer(
                              height: mediaQueryHeight * .7,
                              spread: 2,
                              depth: 60,
                              borderRadius: 14,
                              color: color,
                              parentColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              child: UserListView(games: query.isNotEmpty ? queryUsers : allFetchedUsers, showLimit: query.isEmpty ? 20 : queryUsers.length, isFollowing: false));
                        },
                      )
                    ]);
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return Container();
                });
          }),
        ),
      ]),
    );
  }
}
