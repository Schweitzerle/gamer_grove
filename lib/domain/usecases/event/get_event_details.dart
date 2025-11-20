// ==================================================

// lib/domain/usecases/events/get_event_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetEventDetails extends UseCase<Event, GetEventDetailsParams> {

  GetEventDetails(this.repository);
  final EventRepository repository;

  @override
  Future<Either<Failure, Event>> call(GetEventDetailsParams params) async {
    if (params.eventId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid event ID'));
    }

    return repository.getEventDetails(params.eventId);
  }
}

class GetEventDetailsParams extends Equatable {

  const GetEventDetailsParams({required this.eventId});
  final int eventId;

  @override
  List<Object> get props => [eventId];
}


