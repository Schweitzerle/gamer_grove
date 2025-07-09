// ==================================================

// lib/domain/usecases/events/get_events_by_date_range.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../repositories/event_repository.dart';
import '../base_usecase.dart';

class GetEventsByDateRange extends UseCase<List<Event>, GetEventsByDateRangeParams> {
  final EventRepository repository;

  GetEventsByDateRange(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetEventsByDateRangeParams params) async {
    if (params.startDate != null &&
        params.endDate != null &&
        params.startDate!.isAfter(params.endDate!)) {
      return const Left(ValidationFailure(message: 'Start date cannot be after end date'));
    }

    return await repository.getEventsByDateRange(
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetEventsByDateRangeParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  const GetEventsByDateRangeParams({
    this.startDate,
    this.endDate,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [startDate, endDate, limit];
}

