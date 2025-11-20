// ==========================================

// lib/domain/usecases/game/get_all_genres.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/genre.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetAllGenres extends NoParamsUseCase<List<Genre>> {

  GetAllGenres(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Genre>>> call() async {
    return repository.getAllGenres();
  }
}

