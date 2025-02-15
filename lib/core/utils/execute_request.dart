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
      if (statusCode != null) {
        switch (statusCode) {
          case StatusCode.badRequest:
            return "Permintaan tidak valid";
          case StatusCode.unauthorized:
            return "User tidak terotentikasi";
          case StatusCode.forbidden:
            return "User tidak memiliki hak akses";
          case StatusCode.notFound:
            return "Data tidak ditemukan";
          case StatusCode.conflict:
            return 'Konflik';

          case StatusCode.internalServerError:
            return "Kesalahan server internal";
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
