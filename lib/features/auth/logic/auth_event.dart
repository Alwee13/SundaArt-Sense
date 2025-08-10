part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// Event yang dipicu saat status user berubah (dari stream)
class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);
}

// Event yang dipicu saat tombol logout ditekan
class AuthSignOutRequested extends AuthEvent {}
