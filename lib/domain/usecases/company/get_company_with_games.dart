// ==================================================
// GameEngine USE CASE IMPLEMENTATION
// ==================================================

// lib/domain/usecases/gameEngine/get_game_engine_with_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetCompleteCompanyDetails extends UseCase<Company, GetCompleteCompanyDetailsParams> {
  final GameRepository repository;

  GetCompleteCompanyDetails(this.repository);

  @override
  Future<Either<Failure, Company>> call(GetCompleteCompanyDetailsParams params) async {
    return await repository.getCompanyDetails(params.companyId, params.userId);
  }
}

class GetCompleteCompanyDetailsParams {
  final int companyId;
  final String? userId;

  GetCompleteCompanyDetailsParams({
    required this.companyId,
    this.userId,
  });
}