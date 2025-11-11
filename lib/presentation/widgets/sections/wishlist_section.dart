// lib/presentation/widgets/wishlist_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import '../../blocs/game/game_bloc.dart';
import '../sections/base_game_section.dart';

class WishlistSection extends BaseGameSection {
  final String? username;

  const WishlistSection(
      {super.key, super.currentUserId, super.gameBloc, this.username});

  @override
  String get title =>
      username != null ? "Wishlisted by $username" : 'My Wishlist';

  @override
  String get subtitle => username != null
      ? 'Games $username wants to play'
      : 'Games you want to play';

  @override
  IconData get icon => Icons.favorite;

  @override
  void onViewAllPressed(BuildContext context) {
    final userId = currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }
    // Directly navigate to the dedicated page with the user's ID
    Navigations.navigateToUserWishlist(context, userId: userId);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    // The BlocListener is removed, and we just build the content.
    return _buildContent(context, state);
  }

  Widget _buildContent(BuildContext context, GameState state) {
    if (state is UserWishlistLoading || state is GrovePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is UserWishlistLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection(
            'Your wishlist is empty', Icons.favorite_border, context);
      }
      return buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded) {
      if (state.userWishlist.isEmpty) {
        return buildEmptySection(
            'Your wishlist is empty', Icons.favorite_border, context);
      }
      return buildHorizontalGameList(state.userWishlist.take(10).toList());
    } else if (state is GameError) {
      return buildErrorSection('Failed to load wishlist', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (currentUserId != null && gameBloc != null) {
      gameBloc!.add(LoadUserWishlistEvent(currentUserId!));
    }
  }
}
