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
    this.profilePicture, // Non-const empty File instance
    this.status = SignupStatus.loading,
  });

  final String message;
  final SignupStatus status;
  final String email;
  final String password;
  final String username; // Add this field
  final String name;     // Add this field
  final XFile? profilePicture; // Add this field

  SignupState copyWith({
    String? email,
    String? password,
    String? username, // Add this parameter
    String? name,     // Add this parameter
    XFile? profilePicture,
    SignupStatus? status,
    String? message,
  }) {
    return SignupState(
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username, // Update this line
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture, // Update this line
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
    username, // Add this line
    name,     // Add this line
    profilePicture,
  ];
}
