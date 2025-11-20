// lib/domain/usecases/event/advanced_event_search.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/search/event_search_filters.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class AdvancedEventSearch
    extends UseCase<List<Event>, AdvancedEventSearchParams> {

  AdvancedEventSearch(this.repository);
  final EventRepository repository;

  @override
  Future<Either<Failure, List<Event>>> call(
      AdvancedEventSearchParams params,) async {
    // No Validation needed for now
    /* if ((params.textQuery?.isEmpty ?? true) && !params.filters.hasFilters) {
      return const Left(ValidationFailure(message: 'Text query or filters required'));
    } */

    return repository.advancedEventSearch(
      filters: params.filters,
      textQuery: params.textQuery,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class AdvancedEventSearchParams extends Equatable {

  const AdvancedEventSearchParams({
    required this.filters, this.textQuery,
    this.limit = 20,
    this.offset = 0,
  });
  final String? textQuery;
  final EventSearchFilters filters;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [textQuery, filters, limit, offset];
}
