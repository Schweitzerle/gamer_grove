// ==========================================

// lib/domain/usecases/discovery/get_hidden_gems.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetHiddenGems extends UseCase<List<Game>, GetHiddenGemsParams> {
  final GameRepository repository;

  GetHiddenGems(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetHiddenGemsParams params) async {
    return await repository.getHiddenGems(
      limit: params.limit,
      minRating: params.minRating,
      maxHypes: params.maxHypes,
    );
  }
}

class GetHiddenGemsParams extends Equatable {
  final int limit;
  final double minRating;
  final int maxHypes;

  const GetHiddenGemsParams({
    this.limit = 20,
    this.minRating = 80.0,
    this.maxHypes = 100,
  });

  @override
  List<Object> get props => [limit, minRating, maxHypes];
}