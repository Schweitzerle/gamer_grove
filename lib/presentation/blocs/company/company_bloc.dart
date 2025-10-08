// ==================================================
// PLATFORM BLOC IMPLEMENTATION
// ==================================================

// lib/presentation/blocs/platform/game_engine_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/gameEngine/get_game_engine_with_games.dart';
import 'package:gamer_grove/presentation/blocs/company/company_event.dart';
import 'package:gamer_grove/presentation/blocs/company/company_state.dart';
import '../../../core/utils/game_enrichment_utils.dart';
import '../../../domain/usecases/company/get_company_with_games.dart';
import '../../../domain/usecases/platform/get_platform_with_games.dart';
import 'game_engine_event.dart';
import 'game_engine_state.dart';

class CompanyBloc extends Bloc<CompanyBloc, CompanyState> {
  final GetCompleteCompanyDetails getCompleteCompanyDetails;
  CompanyBloc({
    required this.getCompleteCompanyDetails,
  }) : super(CompanyInitial()) {
    on<GetC>(_onGetGameEngineDetails);
    on<ClearCompanyEvent>(_onClearGameEngine);
  }

  Future<void> _onGetGameEngineDetails(
      GetGameEngineDetailsEvent event,
      Emitter<GameEngineState> emit,
      ) async {
    emit(CompanyLoading());

    final result = await getCompleteCompanyDetails(
      GetGameEngineWithGamesParams(
        gameEngineId: event.companyId,
        includeGames: event.includeGames,
      ),
    );

    await result.fold(
          (failure) async {
        emit(GameEngineError(message: failure.message));
      },
          (gameEngineWithGames) async {
        // 🔧 ENRICHMENT LOGIC mit GameEnrichmentUtils
        if (event.userId != null && gameEngineWithGames.games.isNotEmpty) {
          try {
            print('🎮 GameEngineBloc: Enriching gameEngine games with GameEnrichmentUtils...');

            // Verwende die Utils für Game Enrichment
            final enrichedGames = await GameEnrichmentUtils.enrichGameEngineGames(
              gameEngineWithGames.games,
              event.userId!,
            );

            // Debug Stats
            GameEnrichmentUtils.printEnrichmentStats(enrichedGames, context: 'GameEngine');

            emit(GameEngineDetailsLoaded(
              company: gameEngineWithGames.gameEngine,
              games: enrichedGames,
            ));
          } catch (e) {
            print('❌ GameEngineBloc: Failed to enrich games: $e');
            emit(GameEngineDetailsLoaded(
              company: gameEngineWithGames.gameEngine,
              games: gameEngineWithGames.games,
            ));
          }
        } else {
          emit(GameEngineDetailsLoaded(
            company: gameEngineWithGames.gameEngine,
            games: gameEngineWithGames.games,
          ));
        }
      },
    );
  }

  Future<void> _onClearGameEngine(
      ClearGameEngineEvent event,
      Emitter<GameEngineState> emit,
      ) async {
    emit(GameEngineInitial());
  }
}