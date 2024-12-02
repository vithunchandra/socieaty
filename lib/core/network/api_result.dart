sealed class ApiResult<T> {}

class Success<T> extends ApiResult<T> {
  final T data;
  Success({required this.data});
}

class Error extends ApiResult<Never> {
  final String message;
  Error({required this.message});
}
