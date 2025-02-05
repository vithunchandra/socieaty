import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/post/post/model/create_post_response.dart';
import 'package:socieaty/features/post/post/model/get_post_response.dart';
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
    debugPrint("${data.toJson()}");
    FormData formData = FormData.fromMap({
      ...data.toJson(),
      'hashtags[]': data.hashtags.isEmpty ? [''] : data.hashtags,
    });
    for (File media in medias) {
      formData.files.addAll([
        MapEntry("medias", await MultipartFile.fromFile(media.path)),
      ]);
    }
    debugPrint("${formData.fields}");

    return executeRequest<CreatePostResponse>(
      requestFunction: () => _dio.post('post/', data: formData),
      successParser: (data) => CreatePostResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetPostResponse>> getPost(String postId) {
    return executeRequest<GetPostResponse>(
      requestFunction: () => _dio.get('post/$postId'),
      successParser: (data) => GetPostResponse.fromJson(data),
    );
  }

  Future<ApiResult<LikePostResponse>> likePost(String postId, bool isLiked) {
    return executeRequest<LikePostResponse>(
      requestFunction: () => _dio.put('post/$postId/like', data: {'isLiked': isLiked}),
      successParser: (data) => LikePostResponse.fromJson(data),
    );
  }
}
