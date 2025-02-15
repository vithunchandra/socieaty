import 'package:socieaty/shared/models/network_error.dart';

sealed class ApiResult<T> {}

class Success<T> extends ApiResult<T> {
  final T data;
  Success({required this.data});
}

class Error extends ApiResult<Never> {
  final NetworkError error;
  Error({required this.error});
}
