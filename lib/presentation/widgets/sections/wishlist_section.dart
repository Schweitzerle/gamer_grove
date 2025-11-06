// lib/presentation/widgets/wishlist_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🆕 ADD: Für BlocProvider
import '../../../core/utils/navigations.dart';
import '../../../domain/entities/game/game.dart';
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
    // 🆕 State vom GameBloc abrufen
    final gameBloc = context.read<GameBloc>();
    final currentState = gameBloc.state;

    List<Game> wishlistGames = [];

    // Games aus dem aktuellen State extrahieren
    if (currentState is UserWishlistLoaded) {
      wishlistGames = currentState.games;
    } else if (currentState is GrovePageLoaded) {
      wishlistGames = currentState.userWishlist;
    } else if (currentState is HomePageLoaded &&
        currentState.userWishlist != null) {
      wishlistGames = currentState.userWishlist!;
    }

    // Navigation mit den gefundenen Games
    if (wishlistGames.isNotEmpty) {
      Navigations.navigateToUserWishlist(context, wishlistGames);
    } else {
      // Fallback: Lade Wishlist zuerst
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading wishlist...')),
      );
      if (currentUserId != null && this.gameBloc != null) {
        this.gameBloc!.add(LoadUserWishlistEvent(currentUserId!));
      }
    }
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
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
    } else if (state is HomePageLoaded && state.userWishlist != null) {
      // Backup für HomePageLoaded (falls irgendwo noch verwendet)
      if (state.userWishlist!.isEmpty) {
        return buildEmptySection(
            'Your wishlist is empty', Icons.favorite_border, context);
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
