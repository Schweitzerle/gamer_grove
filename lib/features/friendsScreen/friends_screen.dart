import 'package:clay_containers/widgets/clay_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:profile_view/profile_view.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    initialize();
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

  Future<void> initialize() async {
    await Future.wait(
        [_parseFollowers()]);
  }

  Future<List<FirebaseUserModel>> _parseUsers() async {
    return FirebaseService().getUsersByQuery(query);
  }

  Future<void> _parseFollowers() async {
    final currentUser = getIt<FirebaseUserModel>();
    List<FirebaseUserModel> followers = [];
    for (var value in currentUser.following.values) {
      FirebaseUserModel firebaseUserModel =
          await FirebaseService().getSingleUserData(value);
      followers.add(firebaseUserModel);
    }
    if (followers.isEmpty || followers.length < 10) {
      _searchBarController.show();
    }
    setState(() {
      userFollowing = followers;
    });
  }


  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    Color color = Theme.of(context).colorScheme.tertiaryContainer;
    final currentUser = getIt<FirebaseUserModel>();

    return Scaffold(
      body: Stack(children: [
        ChangeNotifierProvider.value(
          value: currentUser,
          child: Consumer<FirebaseUserModel>(
              builder: (context, firebaseUserModel, child) {
            return  Consumer<FirebaseUserModel>(
                builder: (context, firebaseUserModel, child) {
                  if (firebaseUserModel.following.isNotEmpty) {
                    if (userFollowing.length != firebaseUserModel.following.length) {
                      Future.wait([_parseFollowers()]);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: ListView.builder(
                          itemCount: userFollowing.length,
                          itemBuilder: (context, index) {
                            final user = userFollowing[index];
                            return UserListItem(
                              user: user,
                              buildContext: context,
                            );
                          }),
                    );
                  } else {
                    return Container();
                  }
                });
          }),
        ),

        FloatingSearchBar(
          showAfter: Duration(seconds: 3),
          showCursor: true,
          elevation: 20,
          borderRadius: BorderRadius.circular(14),
          border: BorderSide(color: Theme.of(context).colorScheme.background),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          shadowColor: Theme.of(context).shadowColor,
          iconColor:
              Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          accentColor:
              Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          backdropColor:
              Theme.of(context).colorScheme.background.withOpacity(.7),
          controller: _searchBarController,
          hint: 'Search for Users',
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                query = value;
              });
            }
          },
          scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
          transitionDuration: const Duration(milliseconds: 800),
          transitionCurve: Curves.easeInOut,
          physics: const BouncingScrollPhysics(),
          axisAlignment: true ? 0.0 : -1.0,
          openAxisAlignment: 0.0,
          width: true ? 600 : 500,
          debounceDelay: const Duration(milliseconds: 500),
          onQueryChanged: (value) {
            query = value;
          },
          transition: CircularFloatingSearchBarTransition(),
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                  icon: const Icon(Icons.search), onPressed: () {}),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
          clearQueryOnClose: false,
          builder: (context, transition) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClayContainer(
                height: mediaQueryHeight * .7,
                spread: 2,
                depth: 60,
                borderRadius: 14,
                color: color,
                parentColor: Theme.of(context).colorScheme.onTertiaryContainer,
                child: FutureBuilder<List<FirebaseUserModel>>(
                    future: _parseUsers(),
                    // Assuming _parseUsers calls getUsersByQuery
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        throw snapshot.error!;
                      } else {
                        final users = snapshot.data;
                        if (users == null || users.isEmpty) {
                          // Handle empty list case (optional: show a message)
                          return Center(child: Text('No users found'));
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  return UserListItem(
                                    user: user,
                                    buildContext: context,
                                  );
                                }),
                          );
                        }
                      }
                    }),
              ),
            );
          },
        )
      ]),
    );
  }
}
