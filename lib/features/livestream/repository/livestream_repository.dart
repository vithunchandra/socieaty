import 'package:dio/dio.dart';

class LivestreamRepository {
  late final Dio _dio;

  LivestreamRepository(Dio dio) {
    _dio = dio;
  }
}
