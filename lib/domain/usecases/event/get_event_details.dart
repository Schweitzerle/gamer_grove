// ==================================================

// lib/domain/usecases/events/get_event_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../repositories/event_repository.dart';
import '../base_usecase.dart';

class GetEventDetails extends UseCase<Event, GetEventDetailsParams> {
  final EventRepository repository;

  GetEventDetails(this.repository);

  @override
  Future<Either<Failure, Event>> call(GetEventDetailsParams params) async {
    if (params.eventId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid event ID'));
    }

    return await repository.getEventDetails(params.eventId);
  }
}

class GetEventDetailsParams extends Equatable {
  final int eventId;

  const GetEventDetailsParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}


