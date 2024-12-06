sealed class ViewState<T> {}

class SuccessState<T> extends ViewState<T> {
  final T data;
  SuccessState({required this.data});
}

class ErrorState extends ViewState<Never> {
  final String message;
  ErrorState({required this.message});
}

class LoadingState extends ViewState<Never> {}

class IdleState extends ViewState<Never> {}
