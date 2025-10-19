import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/presentation/blocs/company/company_event.dart';
import 'package:gamer_grove/presentation/blocs/company/company_state.dart';
import '../../../domain/usecases/company/get_company_with_games.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final GetCompanyWithGames getCompanyWithGames;
  final GameEnrichmentService enrichmentService;

  CompanyBloc({
    required this.getCompanyWithGames,
    required this.enrichmentService,
  }) : super(CompanyInitial()) {
    on<GetCompanyDetailsEvent>(_onGetCompanyDetails);
    on<ClearCompanyEvent>(_onClearCompany);
  }

  Future<void> _onGetCompanyDetails(
    GetCompanyDetailsEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyLoading());

    final result = await getCompanyWithGames(
      GetCompanyWithGamesParams(
        companyId: event.companyId,
        includeGames: event.includeGames,
        userId: event.userId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(CompanyError(message: failure.message));
      },
      (companyWithGames) async {
        if (event.userId != null && companyWithGames.games.isNotEmpty) {
          try {
            final enrichedGames = await enrichmentService.enrichGames(
              companyWithGames.games,
              event.userId!,
            );

            emit(CompanyDetailsLoaded(
              company: companyWithGames.company,
              games: enrichedGames,
            ));
          } catch (e) {
            print('❌ CompanyBloc: Failed to enrich games: $e');
            emit(CompanyDetailsLoaded(
              company: companyWithGames.company,
              games: companyWithGames.games,
            ));
          }
        } else {
          emit(CompanyDetailsLoaded(
            company: companyWithGames.company,
            games: companyWithGames.games,
          ));
        }
      },
    );
  }

  Future<void> _onClearCompany(
    ClearCompanyEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyInitial());
  }
}
