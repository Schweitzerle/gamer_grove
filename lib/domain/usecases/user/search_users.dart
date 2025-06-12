// domain/usecases/user/search_users.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/input_validator.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class SearchUsers extends UseCase<List<User>, SearchUsersParams> {
  final UserRepository repository;

  SearchUsers(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(SearchUsersParams params) async {
    final queryValidation = InputValidator.validateSearchQuery(params.query);
    if (queryValidation != null) {
      return Left(ValidationFailure(message: queryValidation));
    }

    return await repository.searchUsers(params.query.trim());
  }
}

class SearchUsersParams extends Equatable {
  final String query;

  const SearchUsersParams({required this.query});

  @override
  List<Object> get props => [query];
}

