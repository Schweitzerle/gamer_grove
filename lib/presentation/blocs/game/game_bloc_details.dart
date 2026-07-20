part of 'game_bloc.dart';

extension _GameBlocDetails on GameBloc {
  Future<void> _onGetGameDetailsWithUserData(
    GetGameDetailsWithUserDataEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    try {
      // First get the game details
      final gameResult = await getGameDetails(
        GameDetailsParams(gameId: event.gameId),
      );

      await gameResult.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(GameError(failure.message));
          }
        },
        (game) async {
          if (event.userId != null) {
            try {
              // Use the new enrichment service - much simpler!
              final enrichedGames = await enrichmentService.enrichGames(
                [game],
                event.userId!,
              );

              if (!emit.isDone) {
                emit(GameDetailsLoaded(enrichedGames.first));
              }
            } catch (e) {
              // If user data fails, still show game without user data
              if (!emit.isDone) {
                emit(GameDetailsLoaded(game));
              }
            }
          } else {
            // No user logged in, show game without user data
            if (!emit.isDone) {
              emit(GameDetailsLoaded(game));
            }
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(GameError('Failed to load game details: $e'));
      }
    }
  }

// Fix for _onGetGameDetails
  Future<void> _onGetGameDetails(
    GetGameDetailsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    final result = await getGameDetails(
      GameDetailsParams(gameId: event.gameId),
    );

    if (!emit.isDone) {
      result.fold(
        (failure) => emit(GameError(failure.message)),
        (game) => emit(GameDetailsLoaded(game)),
      );
    }
  }

  Future<void> _onGetCompleteGameDetails(
    GetCompleteGameDetailsEvent event,
    Emitter<GameState> emit,
  ) async {
    if (emit.isDone) return;

    emit(GameDetailsLoading());

    try {
      // 🆕 Use GetEnhancedGameDetails instead of GetCompleteGameDetails
      final result = await getEnhancedGameDetails(
        GetEnhancedGameDetailsParams.fullDetails(
          gameId: event.gameId,
          userId: event.userId,
        ),
      );

      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(GameError(_mapFailureToMessage(failure)));
          }
        },
        (game) async {
          // Add user data enrichment if userId provided
          if (event.userId != null && !emit.isDone) {
            try {
              final enrichedMainGames =
                  await enrichGamesWithUserData([game], event.userId!);
              var enrichedGame = enrichedMainGames[0];

              enrichedGame = await _enrichGameWithAllNestedUserData(
                enrichedGame,
                event.userId!,
              );

              if (!emit.isDone) {
                emit(GameDetailsLoaded(enrichedGame));
              }
            } catch (e) {
              if (!emit.isDone) {
                emit(GameDetailsLoaded(game)); // Fallback without user data
              }
            }
          } else if (!emit.isDone) {
            emit(GameDetailsLoaded(game));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(GameError('Failed to load game details: $e'));
      }
    }
  }

  /*Future<void> _onGetCompleteGameDetails(
    GetCompleteGameDetailsEvent event,
    Emitter<GameState> emit,
  ) async {
    if (emit.isDone) return; // ✅ Safety check

    emit(GameDetailsLoading());

    try {
      // ✅ Game ohne User-Daten laden (Repository sollte userId = null setzen)
      final result = await getCompleteGameDetails(
        GetCompleteGameDetailsParams(
          gameId: event.gameId,
          userId: null, // ✅ Keine User-Daten im Repository
        ),
      );

      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(GameError(_mapFailureToMessage(failure)));
          }
        },
        (game) async {
          // ✅ User-Daten im BLoC hinzufügen (wie bei Home/Grove)
          if (event.userId != null && !emit.isDone) {
            try {
              // 🔧 FIX 1: Main game enrichen
              final enrichedMainGames =
                  await _enrichGamesWithUserData([game], event.userId!);
              Game enrichedGame = enrichedMainGames[0];

              // 🔧 FIX 2: DANN nested games enrichen (mit dem enriched main game!)
              enrichedGame = await _enrichGameWithAllNestedUserData(
                  enrichedGame, event.userId!);

              if (!emit.isDone) {
                // 🔧 FIX 3: Das final enriched game emiten
                emit(GameDetailsLoaded(enrichedGame));
              }
            } catch (e) {
              if (!emit.isDone) {
                emit(GameDetailsLoaded(game)); // ✅ Fallback ohne User-Daten
              }
            }
          } else if (!emit.isDone) {
            emit(GameDetailsLoaded(game));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(GameError('Failed to load game details: $e'));
      }
    }
  }
   */

// 🆕 UPDATED: Limits für Franchise/Collection
  Future<Game> _enrichGameWithAllNestedUserData(
    Game game,
    String userId,
  ) async {
    try {
      // ⚡ PERFORMANCE LIMITS für große Listen
      const franchiseLimit = 10; // Nur erste 10 Franchise Games enrichen
      const collectionLimit = 10; // Nur erste 10 Collection Games enrichen

      // 1-7. Normale Listen (wie vorher, ohne Limit)
      var enrichedSimilarGames = game.similarGames;
      if (game.similarGames.isNotEmpty) {
        enrichedSimilarGames =
            await enrichGamesWithUserData(game.similarGames, userId);
      }

      var enrichedDLCs = game.dlcs;
      if (game.dlcs.isNotEmpty) {
        enrichedDLCs = await enrichGamesWithUserData(game.dlcs, userId);
      }

      var enrichedExpansions = game.expansions;
      if (game.expansions.isNotEmpty) {
        enrichedExpansions =
            await enrichGamesWithUserData(game.expansions, userId);
      }

      var enrichedStandaloneExpansions = game.standaloneExpansions;
      if (game.standaloneExpansions.isNotEmpty) {
        enrichedStandaloneExpansions =
            await enrichGamesWithUserData(game.standaloneExpansions, userId);
      }

      var enrichedBundles = game.bundles;
      if (game.bundles.isNotEmpty) {
        enrichedBundles = await enrichGamesWithUserData(game.bundles, userId);
      }

      var enrichedRemakes = game.remakes;
      if (game.remakes.isNotEmpty) {
        enrichedRemakes = await enrichGamesWithUserData(game.remakes, userId);
      }

      var enrichedRemasters = game.remasters;
      if (game.remasters.isNotEmpty) {
        enrichedRemasters =
            await enrichGamesWithUserData(game.remasters, userId);
      }

      var enrichedPorts = game.ports;
      if (game.ports.isNotEmpty) {
        enrichedPorts = await enrichGamesWithUserData(game.ports, userId);
      }

      var enrichedExpandedGames = game.expandedGames;
      if (game.expandedGames.isNotEmpty) {
        enrichedExpandedGames =
            await enrichGamesWithUserData(game.expandedGames, userId);
      }

      var enrichedVersionParent =
          game.versionParent != null ? [game.versionParent!] : <Game>[];
      if (game.versionParent != null) {
        enrichedVersionParent = await enrichGamesWithUserData(
          game.versionParent != null ? [game.versionParent!] : [],
          userId,
        );
      }

      var enrichedForks = game.forks;
      if (game.forks.isNotEmpty) {
        enrichedForks = await enrichGamesWithUserData(game.forks, userId);
      }

      var enrichedParentGames =
          game.parentGame != null ? [game.parentGame!] : <Game>[];
      if (game.versionParent != null) {
        enrichedParentGames = await enrichGamesWithUserData(
          game.parentGame != null ? [game.parentGame!] : [],
          userId,
        );
      }

      // 8. 🌟 MAIN FRANCHISE (🆕 MIT LIMIT!)
      var enrichedMainFranchise = game.mainFranchise;
      if (game.mainFranchise?.games != null &&
          game.mainFranchise!.games!.isNotEmpty) {
        final enrichedFranchiseGames = await enrichGamesWithUserData(
          game.mainFranchise!.games!, userId,
          enrichLimit: franchiseLimit, // 🎯 NUR ERSTE 10!
        );

        enrichedMainFranchise = Franchise(
          id: game.mainFranchise!.id,
          checksum: game.mainFranchise!.checksum,
          name: game.mainFranchise!.name,
          slug: game.mainFranchise!.slug,
          url: game.mainFranchise!.url,
          gameIds: game.mainFranchise!.gameIds,
          createdAt: game.mainFranchise!.createdAt,
          updatedAt: game.mainFranchise!.updatedAt,
          games: enrichedFranchiseGames,
        );
      }

      // 9. 🌳 OTHER FRANCHISES (🆕 MIT LIMIT!)
      var enrichedFranchises = game.franchises;
      if (game.franchises.isNotEmpty) {
        enrichedFranchises = [];

        for (final franchise in game.franchises) {
          if (franchise.games != null && franchise.games!.isNotEmpty) {
            final enrichedGames = await enrichGamesWithUserData(
              franchise.games!, userId,
              enrichLimit: franchiseLimit, // 🎯 NUR ERSTE 10!
            );

            enrichedFranchises.add(
              Franchise(
                id: franchise.id,
                checksum: franchise.checksum,
                name: franchise.name,
                slug: franchise.slug,
                url: franchise.url,
                gameIds: franchise.gameIds,
                createdAt: franchise.createdAt,
                updatedAt: franchise.updatedAt,
                games: enrichedGames,
              ),
            );
          } else {
            enrichedFranchises.add(franchise);
          }
        }
      }

      // 10. 📚 COLLECTIONS (🆕 MIT LIMIT!)
      var enrichedCollections = game.collections;
      if (game.collections.isNotEmpty) {
        enrichedCollections = [];

        for (final collection in game.collections) {
          if (collection.games != null && collection.games!.isNotEmpty) {
            final enrichedGames = await enrichGamesWithUserData(
              collection.games!, userId,
              enrichLimit: collectionLimit, // 🎯 NUR ERSTE 10!
            );

            enrichedCollections.add(
              Collection(
                id: collection.id,
                checksum: collection.checksum,
                name: collection.name,
                slug: collection.slug,
                url: collection.url,
                asChildRelationIds: collection.asChildRelationIds,
                asParentRelationIds: collection.asParentRelationIds,
                gameIds: collection.gameIds,
                typeId: collection.typeId,
                createdAt: collection.createdAt,
                updatedAt: collection.updatedAt,
                games: enrichedGames,
              ),
            );
          } else {
            enrichedCollections.add(collection);
          }
        }
      }

      // Rest wie vorher...
      final enrichedGame = game.copyWith(
        similarGames: enrichedSimilarGames,
        dlcs: enrichedDLCs,
        expansions: enrichedExpansions,
        standaloneExpansions: enrichedStandaloneExpansions,
        bundles: enrichedBundles,
        remakes: enrichedRemakes,
        remasters: enrichedRemasters,
        mainFranchise: enrichedMainFranchise,
        franchises: enrichedFranchises,
        collections: enrichedCollections,
        ports: enrichedPorts,
        expandedGames: enrichedExpandedGames,
        versionParent:
            enrichedVersionParent.isNotEmpty ? enrichedVersionParent[0] : null,
        forks: enrichedForks,
        parentGame:
            enrichedParentGames.isNotEmpty ? enrichedParentGames[0] : null,
      );

      return enrichedGame;
    } catch (e) {
      return game;
    }
  }

  Future<void> _onGetSimilarGames(
    GetSimilarGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await getSimilarGames(event.gameId);

    result.fold(
      (failure) => emit(GameError(_mapFailureToMessage(failure))),
      (games) => emit(SimilarGamesLoaded(games)),
    );
  }

  Future<void> _onGetGameDLCs(
    GetGameDLCsEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await getGameDLCs(event.gameId);

    result.fold(
      (failure) => emit(GameError(_mapFailureToMessage(failure))),
      (dlcs) => emit(GameDLCsLoaded(dlcs)),
    );
  }

  Future<void> _onGetGameExpansions(
    GetGameExpansionsEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await getGameExpansions(event.gameId);

    result.fold(
      (failure) => emit(GameError(_mapFailureToMessage(failure))),
      (expansions) => emit(GameExpansionsLoaded(expansions)),
    );
  }

  /// Handler for complete franchise games - enriches existing games
  Future<void> _onLoadCompleteFranchiseGames(
    LoadCompleteFranchiseGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    try {
      // ✅ Einfach die übergebenen Games enrichen, keine Repository-Calls!
      final enrichedGames = event.userId != null
          ? await enrichGamesWithUserData(event.games, event.userId!)
          : event.games;

      emit(
        CompleteFranchiseGamesLoaded(
          franchiseId: event.franchiseId,
          franchiseName: event.franchiseName,
          games: enrichedGames,
        ),
      );
    } catch (e) {
      emit(GameError('Failed to enrich franchise games: $e'));
    }
  }

  /// Handler for complete collection games - enriches existing games
  Future<void> _onLoadCompleteCollectionGames(
    LoadCompleteCollectionGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    try {
      // ✅ Einfach die übergebenen Games enrichen, keine Repository-Calls!
      final enrichedGames = event.userId != null
          ? await enrichGamesWithUserData(event.games, event.userId!)
          : event.games;

      emit(
        CompleteCollectionGamesLoaded(
          collectionId: event.collectionId,
          collectionName: event.collectionName,
          games: enrichedGames,
        ),
      );
    } catch (e) {
      emit(GameError('Failed to enrich collection games: $e'));
    }
  }
}
