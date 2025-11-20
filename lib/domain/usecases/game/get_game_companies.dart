// lib/domain/usecases/game/get_game_companies.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameCompanies implements UseCase<List<Company>, GetGameCompaniesParams> {

  GetGameCompanies(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Company>>> call(GetGameCompaniesParams params) async {
    return repository.getCompanies(
      ids: params.ids,
      search: params.search,
    );
  }
}

class GetGameCompaniesParams {

  GetGameCompaniesParams({
    this.ids,
    this.search,
  });
  final List<int>? ids;
  final String? search;
}