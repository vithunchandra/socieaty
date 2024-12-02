import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(Ref ref, {required String url}) {
  return Dio(BaseOptions(
    baseUrl: url,
    connectTimeout: Duration(seconds: 30),
  ));
}
