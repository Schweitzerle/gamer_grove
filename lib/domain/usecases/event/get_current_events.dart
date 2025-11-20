// ==================================================

// lib/domain/usecases/events/get_current_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetCurrentEvents extends UseCase<List<Event>, GetCurrentEventsParams> {

  GetCurrentEvents(this.repository);
  final EventRepository repository;

  @override
  Future<Either<Failure, List<Event>>> call(GetCurrentEventsParams params) async {
    return repository.getCurrentEvents(limit: params.limit);
  }
}

class GetCurrentEventsParams extends Equatable {

  const GetCurrentEventsParams({this.limit = 10});
  final int limit;

  @override
  List<Object> get props => [limit];
}

