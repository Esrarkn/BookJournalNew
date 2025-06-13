import 'package:book_journal/data/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signIn(event.email, event.password);
        emit(AuthAuthenticated(user!));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signUp(event.email, event.password);
        emit(AuthAuthenticated(user!));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignOutEvent>((event, emit) async {
      await _authRepository.signOut();
      emit(AuthInitial());
    });
  }
}
