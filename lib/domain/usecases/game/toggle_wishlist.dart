// domain/usecases/game/toggle_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class ToggleWishlist extends UseCase<void, ToggleWishlistParams> {

  ToggleWishlist(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, void>> call(ToggleWishlistParams params) async {
    return repository.toggleWishlist(
      params.gameId,
      params.userId,
    );
  }
}

class ToggleWishlistParams extends Equatable {

  const ToggleWishlistParams({
    required this.gameId,
    required this.userId,
  });
  final int gameId;
  final String userId;

  @override
  List<Object> get props => [gameId, userId];
}

