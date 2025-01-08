import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/post/post/model/create_post_response.dart';
import 'package:socieaty/features/post/post/model/like_post_response.dart';
import 'package:socieaty/features/post/post/viewstate/create_post_form_state.dart';

part 'post_repository.g.dart';

@riverpod
PostRepository postRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return PostRepository(
    ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class PostRepository {
  late final Dio _dio;

  PostRepository(Dio dio) {
    _dio = dio;
  }

  Future<ApiResult<CreatePostResponse>> createPost(CreatePostFormState data, List<File> medias) async {
    try {
      FormData formData = FormData.fromMap(data.toJson());
      for (File media in medias) {
        formData.files.addAll([
          MapEntry("medias", await MultipartFile.fromFile(media.path)),
        ]);
      }
      final response = await _dio.post('post/', data: formData);
      debugPrint(response.data.toString());
      return Success(data: CreatePostResponse.fromJson(response.data));
    } on DioException catch (error) {
      return Error(message: error.extractMesage());
    } on Exception catch (error) {
      return Error(message: error.toString());
    }
  }

  Future<ApiResult<LikePostResponse>> likePost(String postId) async {
    try {
      final response = await _dio.put('post/$postId/like}');
      return Success(data: LikePostResponse.fromJson(response.data));
    } on DioException catch (error) {
      return Error(message: error.extractMesage());
    } on Exception catch (error) {
      return Error(message: error.toString());
    }
  }
}
