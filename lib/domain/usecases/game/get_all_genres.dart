// ==========================================

// lib/domain/usecases/game/get_all_genres.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/genre.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetAllGenres extends NoParamsUseCase<List<Genre>> {
  final GameRepository repository;

  GetAllGenres(this.repository);

  @override
  Future<Either<Failure, List<Genre>>> call() async {
    return await repository.getAllGenres();
  }
}

