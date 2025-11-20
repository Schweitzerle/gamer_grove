// ==========================================

// lib/domain/usecases/game/get_all_platforms.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetAllPlatforms extends NoParamsUseCase<List<Platform>> {

  GetAllPlatforms(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Platform>>> call() async {
    return repository.getAllPlatforms();
  }
}

