// ==================================================

// lib/domain/usecases/events/get_upcoming_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUpcomingEvents extends UseCase<List<Event>, GetUpcomingEventsParams> {

  GetUpcomingEvents(this.repository);
  final EventRepository repository;

  @override
  Future<Either<Failure, List<Event>>> call(GetUpcomingEventsParams params) async {
    return repository.getUpcomingEvents(limit: params.limit);
  }
}

class GetUpcomingEventsParams extends Equatable {

  const GetUpcomingEventsParams({this.limit = 10});
  final int limit;

  @override
  List<Object> get props => [limit];
}

