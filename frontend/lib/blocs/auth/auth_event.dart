import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthVerificationRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerificationRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetConfirmationRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const AuthPasswordResetConfirmationRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

class AuthLogoutRequested extends AuthEvent {} 