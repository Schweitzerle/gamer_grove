//UPDATE
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetCompanyWithGames
    extends UseCase<CompanyWithGames, GetCompanyWithGamesParams> {
  final GameRepository repository;

  GetCompanyWithGames(this.repository);

  @override
  Future<Either<Failure, CompanyWithGames>> call(
      GetCompanyWithGamesParams params) async {
    try {
      print('🎮 UseCase: Getting company details for ID: ${params.companyId}');
      print('🎮 UseCase: Include games: ${params.includeGames}');

      final companyResult =
          await repository.getCompanyDetails(params.companyId, params.userId);

      if (companyResult.isLeft()) {
        return companyResult.fold(
          (failure) {
            print('❌ UseCase: Repository failed: ${failure.message}');
            return Left(failure);
          },
          (company) => throw Exception('Unexpected success'),
        );
      }

      final company = companyResult.fold(
        (l) => throw Exception('Unexpected failure'),
        (r) => r,
      );

      print('✅ UseCase: Company loaded: ${company.name}');

      List<Game> games = [];

      if (params.includeGames) {
        print('🎮 UseCase: Loading games for company: ${company.name}');

        final gamesResult = await repository.getGamesByCompany(
          companyIds: [company.id],
          limit: params.limit,
          offset: 0,
        );

        games = gamesResult.fold(
          (failure) {
            print('❌ UseCase: Failed to load games: ${failure.message}');
            return <Game>[];
          },
          (gamesList) {
            print('✅ UseCase: Loaded ${gamesList.length} games for company');
            return gamesList;
          },
        );
      }

      final result = CompanyWithGames(
        company: company,
        games: games,
      );

      print(
          '🎯 UseCase: Final result - ${result.company.name} with ${result.games.length} games');
      return Right(result);
    } catch (e) {
      print('❌ UseCase: Exception occurred: $e');
      print('📍 UseCase: Exception type: ${e.runtimeType}');
      return Left(
          ServerFailure(message: 'Failed to load company with games: $e'));
    }
  }
}

class GetCompanyWithGamesParams extends Equatable {
  final int companyId;
  final bool includeGames;
  final int limit;
  final String? userId;

  const GetCompanyWithGamesParams({
    required this.companyId,
    this.includeGames = true,
    this.limit = 10,
    this.userId,
  });

  @override
  List<Object?> get props => [companyId, includeGames, limit, userId];
}

class CompanyWithGames extends Equatable {
  final Company company;
  final List<Game> games;

  const CompanyWithGames({
    required this.company,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [company, games];
}
