// ==========================================

// lib/domain/usecases/user/search_users.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class SearchUsers extends UseCase<List<User>, SearchUsersParams> {
  final UserRepository repository;

  SearchUsers(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(SearchUsersParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    if (params.query.trim().length < 2) {
      return const Left(ValidationFailure(message: 'Search query must be at least 2 characters'));
    }

    return await repository.searchUsers(
      query: params.query.trim(),
      currentUserId: params.currentUserId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchUsersParams extends Equatable {
  final String query;
  final String? currentUserId;
  final int limit;
  final int offset;

  const SearchUsersParams({
    required this.query,
    this.currentUserId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, currentUserId, limit, offset];
}

