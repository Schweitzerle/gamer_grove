// domain/usecases/game/toggle_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class ToggleWishlist extends UseCase<void, ToggleWishlistParams> {
  final GameRepository repository;

  ToggleWishlist(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleWishlistParams params) async {
    return await repository.toggleWishlist(
      gameId: params.gameId,
      userId: params.userId,
    );
  }
}

class ToggleWishlistParams extends Equatable {
  final int gameId;
  final String userId;

  const ToggleWishlistParams({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object> get props => [gameId, userId];
}

