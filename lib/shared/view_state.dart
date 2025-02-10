sealed class ViewState<T> {
  const ViewState();
}

class SuccessState<T> extends ViewState<T> {
  final T data;
  SuccessState({required this.data});
}

class ErrorState extends ViewState<Never> {
  final String message;
  ErrorState({required this.message});
}

class LoadingState<T> extends ViewState<T> {
  const LoadingState();
}

class IdleState extends ViewState<Never> {}
