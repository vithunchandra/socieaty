sealed class AuthState<T> {}

class SignedIn<T> extends AuthState<T> {
  final T user;
  SignedIn({required this.user});
}

class Loading extends AuthState<Never> {}

class SignedOut extends AuthState<Never> {}
