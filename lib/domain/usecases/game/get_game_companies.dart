// lib/domain/usecases/game/get_game_companies.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/company/company.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameCompanies implements UseCase<List<Company>, GetGameCompaniesParams> {
  final GameRepository repository;

  GetGameCompanies(this.repository);

  @override
  Future<Either<Failure, List<Company>>> call(GetGameCompaniesParams params) async {
    return await repository.getCompanies(
      ids: params.ids,
      search: params.search,
    );
  }
}

class GetGameCompaniesParams {
  final List<int>? ids;
  final String? search;

  GetGameCompaniesParams({
    this.ids,
    this.search,
  });
}