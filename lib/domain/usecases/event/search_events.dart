// ==========================================

// lib/domain/usecases/events/search_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class SearchEvents extends UseCase<List<Event>, SearchEventsParams> {
  final GameRepository repository;

  SearchEvents(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(SearchEventsParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    return await repository.searchEvents(params.query.trim());
  }
}

class SearchEventsParams extends Equatable {
  final String query;

  const SearchEventsParams({required this.query});

  @override
  List<Object> get props => [query];
}

