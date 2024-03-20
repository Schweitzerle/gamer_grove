part of 'signup_bloc.dart';

enum SignupStatus {
  success,
  failure,
  loading,
}

class SignupState extends Equatable {
  SignupState({
    this.email = '',
    this.password = '',
    this.username = '',
    this.name = '',
    this.message = '',
    this.profilePicture,
    this.status = SignupStatus.loading,
  });

  final String message;
  final SignupStatus status;
  final String email;
  final String password;
  final String username;
  final String name;
  final XFile? profilePicture;

  SignupState copyWith({
    String? email,
    String? password,
    String? username,
    String? name,
    XFile? profilePicture,
    SignupStatus? status,
    String? message,
  }) {
    return SignupState(
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    message,
    status,
    email,
    password,
    username,
    name,
    profilePicture,
  ];
}
