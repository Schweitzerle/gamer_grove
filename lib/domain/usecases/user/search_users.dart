// ==========================================

// lib/domain/usecases/user/search_users.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class SearchUsers extends UseCase<List<User>, SearchUsersParams> {

  SearchUsers(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<User>>> call(SearchUsersParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    if (params.query.trim().length < 2) {
      return const Left(ValidationFailure(message: 'Search query must be at least 2 characters'));
    }

    return repository.searchUsers(
      query: params.query.trim(),
      currentUserId: params.currentUserId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchUsersParams extends Equatable {

  const SearchUsersParams({
    required this.query,
    this.currentUserId,
    this.limit = 20,
    this.offset = 0,
  });
  final String query;
  final String? currentUserId;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [query, currentUserId, limit, offset];
}

