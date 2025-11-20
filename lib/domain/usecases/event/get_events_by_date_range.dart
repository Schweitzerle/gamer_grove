// ==================================================

// lib/domain/usecases/events/get_events_by_date_range.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetEventsByDateRange extends UseCase<List<Event>, GetEventsByDateRangeParams> {

  GetEventsByDateRange(this.repository);
  final EventRepository repository;

  @override
  Future<Either<Failure, List<Event>>> call(GetEventsByDateRangeParams params) async {
    if (params.startDate != null &&
        params.endDate != null &&
        params.startDate!.isAfter(params.endDate!)) {
      return const Left(ValidationFailure(message: 'Start date cannot be after end date'));
    }

    return repository.getEventsByDateRange(
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetEventsByDateRangeParams extends Equatable {

  const GetEventsByDateRangeParams({
    this.startDate,
    this.endDate,
    this.limit = 50,
  });
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  @override
  List<Object?> get props => [startDate, endDate, limit];
}

