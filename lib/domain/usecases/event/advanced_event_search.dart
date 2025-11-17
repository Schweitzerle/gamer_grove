// lib/domain/usecases/event/advanced_event_search.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../entities/search/event_search_filters.dart';
import '../../repositories/event_repository.dart';
import '../base_usecase.dart';

class AdvancedEventSearch extends UseCase<List<Event>, AdvancedEventSearchParams> {
  final EventRepository repository;

  AdvancedEventSearch(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(AdvancedEventSearchParams params) async {
    if ((params.textQuery?.isEmpty ?? true) && !params.filters.hasFilters) {
      return const Left(ValidationFailure(message: 'Text query or filters required'));
    }

    return await repository.advancedEventSearch(
      filters: params.filters,
      textQuery: params.textQuery,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class AdvancedEventSearchParams extends Equatable {
  final String? textQuery;
  final EventSearchFilters filters;
  final int limit;
  final int offset;

  const AdvancedEventSearchParams({
    this.textQuery,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [textQuery, filters, limit, offset];
}
