import 'dart:convert';
import 'dart:io';
import 'package:auth_service/auth.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({
    required AuthService authService,
  })  : _authService = authService,
        super(SignupState()) {
    on<SignupButtonPressedEvent>(_handleCreateAccountEvent);
    on<SignupEmailChangedEvent>(_handleSignupEmailChangedEvent);
    on<SignupPasswordChangedEvent>(_handleSignupPasswordChangedEvent);
    on<SignupUsernameChangedEvent>(_handleSignupUsernameChangedEvent);
    on<SignupNameChangedEvent>(_handleSignupNameChangedEvent);
    on<SignupProfilePictureChangedEvent>(_handleSignupProfilePictureChangedEvent); // Add this line
  }

  final AuthService _authService;

  Future<void> _handleSignupEmailChangedEvent(
      SignupEmailChangedEvent event,
      Emitter<SignupState> emit,
      ) async {
    emit(state.copyWith(email: event.email));
  }

  Future<void> _handleSignupPasswordChangedEvent(
      SignupPasswordChangedEvent event,
      Emitter<SignupState> emit,
      ) async {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _handleSignupUsernameChangedEvent(
      SignupUsernameChangedEvent event,
      Emitter<SignupState> emit,
      ) async {
    emit(state.copyWith(username: event.username));
  }

  Future<void> _handleSignupNameChangedEvent(
      SignupNameChangedEvent event,
      Emitter<SignupState> emit,
      ) async {
    emit(state.copyWith(name: event.name));
  }

  Future<void> _handleSignupProfilePictureChangedEvent( // Add this method
      SignupProfilePictureChangedEvent event,
      Emitter<SignupState> emit,
      ) async {
    emit(state.copyWith(profilePicture: event.profilePicture));
  }

  Future<void> _handleCreateAccountEvent(
      SignupButtonPressedEvent event,
      Emitter<SignupState> emit,
      ) async {
    try {
      File? profilePicture = state.profilePicture;

      // Check if profilePicture is not null
      if (profilePicture != null) {

        print('CreatedUserProfile');
        await _authService.createUserWithEmailAndPassword(
          email: state.email,
          password: state.password,
          username: state.username,
          name: state.name,
          profilePicture: profilePicture,
        );
      }
      emit(state.copyWith(status: SignupStatus.success));
      print("Success of signup");
    } catch (e) {
      emit(state.copyWith(message: e.toString(), status: SignupStatus.failure));
      print("Fail of signup with error ${e.toString()}");
    }
  }

}
