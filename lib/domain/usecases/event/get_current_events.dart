// ==========================================

// lib/domain/usecases/event/get_current_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../repositories/event_repository.dart';
import '../base_usecase.dart';

class GetCurrentEvents extends UseCase<List<Event>, GetCurrentEventsParams> {
  final EventRepository repository;

  GetCurrentEvents(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetCurrentEventsParams params) async {
    return await repository.getCurrentEvents(limit: params.limit);
  }
}

class GetCurrentEventsParams extends Equatable {
  final int limit;

  const GetCurrentEventsParams({this.limit = 10});

  @override
  List<Object> get props => [limit];
}