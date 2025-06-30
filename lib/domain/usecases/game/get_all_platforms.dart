// ==========================================

// lib/domain/usecases/game/get_all_platforms.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/platform/platform.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetAllPlatforms extends NoParamsUseCase<List<Platform>> {
  final GameRepository repository;

  GetAllPlatforms(this.repository);

  @override
  Future<Either<Failure, List<Platform>>> call() async {
    return await repository.getAllPlatforms();
  }
}

