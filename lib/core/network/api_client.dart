import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(Ref ref, {required String url, String? token}) {
  if (token == null) {
    return Dio(BaseOptions(
      baseUrl: url,
      connectTimeout: Duration(seconds: 15),
      sendTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
    ));
  } else {
    return Dio(BaseOptions(baseUrl: url, connectTimeout: Duration(seconds: 15), headers: {'Authorization': "Bearer $token"}));
  }
}
