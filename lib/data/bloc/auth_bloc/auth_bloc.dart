import 'package:bloc/bloc.dart';
import 'package:book_journal/ui/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc(this._firebaseAuth) : super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);  // SignUp event handler eklendi
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
       emit(AuthSuccess(AppUser(
  id: user.uid,
  email: user.email ?? '',
  name: user.displayName,
)));

      } else {
        emit(AuthFailure("Unknown error occurred."));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? "An error occurred."));
    } catch (e) {
      emit(AuthFailure("Unexpected error: ${e.toString()}"));
    }
  }

  // Yeni: Kayıt işlemi için event handler
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        // İstersen burada kullanıcı ismini Firebase profiline update edebilirsin
        await user.updateDisplayName(event.name);
        await user.reload();
        final updatedUser = _firebaseAuth.currentUser;

        emit(AuthSuccess(AppUser(
          id: updatedUser?.uid ?? '',
          email: updatedUser?.email ?? '',
          name: updatedUser?.displayName ?? '',
        )));
      } else {
        emit(AuthFailure("Unknown error occurred."));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? "An error occurred."));
    } catch (e) {
      emit(AuthFailure("Unexpected error: ${e.toString()}"));
    }
  }
}