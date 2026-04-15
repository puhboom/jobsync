import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String provider; // 'google' or 'linkedin'

  const AuthLoginRequested({required this.provider});

  @override
  List<Object?> get props => [provider];
}

class AuthOAuthCallback extends AuthEvent {
  final String code;
  final String provider;

  const AuthOAuthCallback({required this.code, required this.provider});

  @override
  List<Object?> get props => [code, provider];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
