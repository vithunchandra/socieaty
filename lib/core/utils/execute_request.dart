import 'package:dio/dio.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/custom_extension.dart';

Future<ApiResult<T>> executeRequest<T>({
  required Future<Response<dynamic>> Function() requestFunction,
  required T Function(dynamic data) successParser,
}) async {
  try {
    final response = await requestFunction();
    return Success(data: successParser(response.data));
  } on DioException catch (error) {
    return Error(message: error.extractMesage());
  } on Exception catch (error) {
    return Error(message: error.toString());
  }
}
