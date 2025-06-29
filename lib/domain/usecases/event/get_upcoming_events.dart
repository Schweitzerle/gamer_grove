// ==========================================

// lib/domain/usecases/event/get_upcoming_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../repositories/event_repository.dart';
import '../base_usecase.dart';

class GetUpcomingEvents extends UseCase<List<Event>, GetUpcomingEventsParams> {
  final EventRepository repository;

  GetUpcomingEvents(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetUpcomingEventsParams params) async {
    return await repository.getUpcomingEvents(limit: params.limit);
  }
}

class GetUpcomingEventsParams extends Equatable {
  final int limit;

  const GetUpcomingEventsParams({this.limit = 10});

  @override
  List<Object> get props => [limit];
}