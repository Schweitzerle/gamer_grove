import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/features/friendsScreen/friends_screen.dart';
import 'package:gamer_grove/features/home/home_screen.dart';
import 'package:gamer_grove/features/profileScreen/profile_screen.dart';
import 'package:gamer_grove/features/searchScreen/search_screen.dart';
import 'package:gamer_grove/features/watchListScreen/watchlist_and_rated.dart';
import 'package:gamer_grove/model/firebase/firebaseUser.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/repository/firebase/firebase.dart';
import 'package:get_it/get_it.dart';
import 'package:liquid_swipe/Helpers/Helpers.dart';
import 'package:liquid_swipe/PageHelpers/LiquidController.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class LiquidTabBar extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => LiquidTabBar(),
    );
  }

  @override
  _LiquidTabBarState createState() => _LiquidTabBarState();
}

class _LiquidTabBarState extends State<LiquidTabBar> {
  final initialIndex = 2;
  late int currentIndex;
  late PageController controller;

  final List<Widget> pages = [
    WatchlistScreen(),
    FriendsScreen(),
    HomeScreen(),
    GameSearchScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = initialIndex;
    controller = PageController(initialPage: initialIndex);
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBarBubble(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary!,
        color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
        selectedIndex: currentIndex,
        items: [
          BottomBarItem(
            iconData: Icons.collections_bookmark_rounded,
            // label: 'Home',
          ),
          BottomBarItem(
            iconData: Icons.groups,
            // label: 'Chat',
          ),
          BottomBarItem(
            iconData: Icons.videogame_asset,
            // label: 'Notification',
          ),
          BottomBarItem(
            iconData: Icons.search,
            // label: 'Calendar',
          ),
          BottomBarItem(
            iconData: Icons.person,
            // label: 'Setting',
          ),
        ],
        onSelect: (index) {
          setState(() {
            currentIndex = index;
          });
          // Navigate to the corresponding page
          controller.jumpToPage(index);
        },
      ),
      body: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: pages),
    );
  }
}
