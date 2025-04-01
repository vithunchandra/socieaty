import 'package:dio/dio.dart';
import 'package:socieaty/core/enums/status_code.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/shared/models/network_error.dart';

Future<ApiResult<T>> executeRequest<T>({
  required Future<Response<dynamic>> Function() requestFunction,
  required T Function(dynamic data) successParser,
}) async {
  try {
    final response = await requestFunction();
    return Success(data: successParser(response.data));
  } on DioException catch (error) {
    return Error(
      error: NetworkError(
        message: _handleDioError(error),
        statusCode: error.response?.statusCode ?? 0,
      ),
    );
  } on Exception catch (error) {
    return Error(
      error: NetworkError(
        message: error.toString(),
      ),
    );
  } catch (error) {
    return Error(
      error: NetworkError(
        message: error.toString(),
      ),
    );
  }
}

String _handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return "Waktu habis saat mengirim atau menerima data dari server";
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      dynamic errorData;
      try {
        errorData = error.response?.data['message'];
      } catch (err) {
        errorData = "Kesalahan tidak diketahui";
      }
      String? errorMessage;
      if (errorData is String) {
        errorMessage = errorData;
      } else if (errorData is List<dynamic>) {
        errorMessage = errorData.map((e) => e.toString()).join("\n");
      }
      if (statusCode != null) {
        switch (statusCode) {
          case StatusCode.badRequest:
            return errorMessage ?? "Permintaan tidak valid";
          case StatusCode.unauthorized:
            return errorMessage ?? "User tidak terotentikasi";
          case StatusCode.forbidden:
            return errorMessage ?? "User tidak memiliki hak akses";
          case StatusCode.notFound:
            return errorMessage ?? "Data tidak ditemukan";
          case StatusCode.conflict:
            return errorMessage ?? 'Konflik';

          case StatusCode.internalServerError:
            return errorMessage ?? "Kesalahan server internal";
        }
      }
      break;
    case DioExceptionType.cancel:
      break;
    case DioExceptionType.unknown:
      return "Tidak ada koneksi internet";
    case DioExceptionType.badCertificate:
      return "Kesalahan sertifikat server";
    case DioExceptionType.connectionError:
      return "Koneksi ke server gagal";
  }
  return "Kesalahan tidak diketahui";
}
