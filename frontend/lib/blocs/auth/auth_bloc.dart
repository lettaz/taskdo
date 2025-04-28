import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskdo/blocs/auth/auth_event.dart';
import 'package:taskdo/blocs/auth/auth_state.dart';
import 'package:taskdo/data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthVerificationRequested>(_onAuthVerificationRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthPasswordResetConfirmationRequested>(_onAuthPasswordResetConfirmationRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Login requested for ${event.email}');
    emit(AuthLoading());
    try {
      // For development purposes, we can use mockLogin if needed
      // final user = await _authRepository.mockLogin(event.email, event.password);
      
      final user = await _authRepository.login(
        event.email,
        event.password,
        rememberMe: event.rememberMe,
      );
      print('AuthBloc: Login successful for ${user.email}');
      emit(AuthAuthenticated(user));
    } catch (e) {
      print('AuthBloc: Login error - $e');
      if (e.toString() == 'Email not verified') {
        // If email is not verified, emit the verification required state
        print('AuthBloc: Email not verified, redirecting to verification');
        emit(AuthVerificationRequired(event.email));
      } else {
        print('AuthBloc: Emitting failure state with message: ${e.toString()}');
        emit(AuthFailure(e.toString()));
      }
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(event.email, event.password);
      emit(AuthVerificationRequired(event.email));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthVerificationRequested(
    AuthVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Verification requested for ${event.email} with code ${event.code}');
    emit(AuthLoading());
    try {
      final user = await _authRepository.verifyEmail(event.email, event.code);
      print('AuthBloc: Verification successful for ${user.email}');
      emit(AuthAuthenticated(user));
    } catch (e) {
      print('AuthBloc: Verification error - $e');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.requestPasswordReset(event.email);
      emit(AuthPasswordResetSent(event.email));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthPasswordResetConfirmationRequested(
    AuthPasswordResetConfirmationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(
        event.email,
        event.code,
        event.newPassword,
      );
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
} 