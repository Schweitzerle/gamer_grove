// ==========================================

// lib/domain/usecases/user/get_follow_suggestions.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetFollowSuggestions extends UseCase<List<User>, GetFollowSuggestionsParams> {

  GetFollowSuggestions(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<User>>> call(GetFollowSuggestionsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getFollowSuggestions(
      userId: params.userId,
      limit: params.limit,
    );
  }
}

class GetFollowSuggestionsParams extends Equatable {

  const GetFollowSuggestionsParams({
    required this.userId,
    this.limit = 20,
  });
  final String userId;
  final int limit;

  @override
  List<Object> get props => [userId, limit];
}