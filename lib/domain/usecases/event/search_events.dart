// ==================================================

// lib/domain/usecases/events/search_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class SearchEvents extends UseCase<List<Event>, SearchEventsParams> {

  SearchEvents(this.repository);
  final EventRepository repository;

  @override
  Future<Either<Failure, List<Event>>> call(SearchEventsParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    return repository.searchEvents(params.query.trim());
  }
}

class SearchEventsParams extends Equatable {

  const SearchEventsParams({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}
