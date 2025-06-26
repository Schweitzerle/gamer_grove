// lib/presentation/widgets/wishlist_section.dart
import 'package:flutter/material.dart';
import '../../../core/utils/navigations.dart';
import '../../blocs/game/game_bloc.dart';
import '../sections/base_game_section.dart';

class WishlistSection extends BaseGameSection {
  const WishlistSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
  });

  @override
  String get title => 'My Wishlist';

  @override
  String get subtitle => 'Games you want to play';

  @override
  IconData get icon => Icons.favorite;

  @override
  void onViewAllPressed(BuildContext context) {
    Navigations.navigateToWishlist(context);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    if (state is UserWishlistLoading || state is GrovePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is UserWishlistLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection('Your wishlist is empty', Icons.favorite_border, context);
      }
      return buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded) {
      if (state.userWishlist.isEmpty) {
        return buildEmptySection('Your wishlist is empty', Icons.favorite_border, context);
      }
      return buildHorizontalGameList(state.userWishlist.take(10).toList());
    } else if (state is HomePageLoaded && state.userWishlist != null) {
      // Backup für HomePageLoaded (falls irgendwo noch verwendet)
      if (state.userWishlist!.isEmpty) {
        return buildEmptySection('Your wishlist is empty', Icons.favorite_border, context);
      }
      return buildHorizontalGameList(state.userWishlist!.take(10).toList());
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