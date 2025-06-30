// ==========================================

// lib/domain/usecases/user/get_follow_suggestions.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetFollowSuggestions extends UseCase<List<User>, GetFollowSuggestionsParams> {
  final UserRepository repository;

  GetFollowSuggestions(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(GetFollowSuggestionsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getFollowSuggestions(
      userId: params.userId,
      limit: params.limit,
    );
  }
}

class GetFollowSuggestionsParams extends Equatable {
  final String userId;
  final int limit;

  const GetFollowSuggestionsParams({
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object> get props => [userId, limit];
}