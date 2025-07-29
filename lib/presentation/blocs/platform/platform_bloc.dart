// ==================================================
// PLATFORM BLOC IMPLEMENTATION
// ==================================================

// lib/presentation/blocs/platform/game_engine_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_event.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_state.dart';
import '../../../core/utils/game_enrichment_utils.dart';
import '../../../domain/usecases/platform/get_platform_with_games.dart';

class PlatformBloc extends Bloc<PlatformEvent, PlatformState> {
  final GetPlatformWithGames getPlatformWithGames;

  PlatformBloc({
    required this.getPlatformWithGames,
  }) : super(PlatformInitial()) {
    on<GetPlatformDetailsEvent>(_onGetPlatformDetails);
    on<ClearPlatformEvent>(_onClearPlatform);
  }

  Future<void> _onGetPlatformDetails(
      GetPlatformDetailsEvent event,
      Emitter<PlatformState> emit,
      ) async {
    emit(PlatformLoading());

    final result = await getPlatformWithGames(
      GetPlatformWithGamesParams(
        platformId: event.platformId,
        includeGames: event.includeGames,
      ),
    );

    await result.fold(
          (failure) async {
        emit(PlatformError(message: failure.message));
      },
          (platformWithGames) async {
        // 🔧 ENRICHMENT LOGIC mit GameEnrichmentUtils
        if (event.userId != null && platformWithGames.games.isNotEmpty) {
          try {
            print('🎮 PlatformBloc: Enriching platform games with GameEnrichmentUtils...');

            // Verwende die Utils für Game Enrichment
            final enrichedGames = await GameEnrichmentUtils.enrichPlatformGames(
              platformWithGames.games,
              event.userId!,
            );

            // Debug Stats
            GameEnrichmentUtils.printEnrichmentStats(enrichedGames, context: 'Platform');

            emit(PlatformDetailsLoaded(
              platform: platformWithGames.platform,
              games: enrichedGames,
            ));
          } catch (e) {
            print('❌ PlatformBloc: Failed to enrich games: $e');
            emit(PlatformDetailsLoaded(
              platform: platformWithGames.platform,
              games: platformWithGames.games,
            ));
          }
        } else {
          emit(PlatformDetailsLoaded(
            platform: platformWithGames.platform,
            games: platformWithGames.games,
          ));
        }
      },
    );
  }

  Future<void> _onClearPlatform(
      ClearPlatformEvent event,
      Emitter<PlatformState> emit,
      ) async {
    emit(PlatformInitial());
  }
}