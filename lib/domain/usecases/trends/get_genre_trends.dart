// ==========================================

// lib/domain/usecases/trends/get_genre_trends.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/recommendations/genre_trend.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGenreTrends extends UseCase<List<GenreTrend>, GetGenreTrendsParams> {
  final GameRepository repository;

  GetGenreTrends(this.repository);

  @override
  Future<Either<Failure, List<GenreTrend>>> call(GetGenreTrendsParams params) async {
    return await repository.getGenreTrends(
      timeWindow: params.timeWindow,
      limit: params.limit,
    );
  }
}

class GetGenreTrendsParams extends Equatable {
  final Duration? timeWindow;
  final int limit;

  const GetGenreTrendsParams({
    this.timeWindow,
    this.limit = 20,
  });

  GetGenreTrendsParams.lastMonth({this.limit = 20})
      : timeWindow = const Duration(days: 30);

  GetGenreTrendsParams.lastQuarter({this.limit = 20})
      : timeWindow = const Duration(days: 90);

  @override
  List<Object?> get props => [timeWindow, limit];
}