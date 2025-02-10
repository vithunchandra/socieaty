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
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'post_repository.g.dart';

@riverpod
PostRepository postRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  final user = authLocalRepository.getUserData()!;
  return PostRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
    user: user,
  );
}

class PostRepository {
  final Dio dio;
  final SocieatyUser user;

  PostRepository({required this.dio, required this.user});

  Future<ApiResult<CreatePostResponse>> createPost(
      CreatePostFormState data, List<File> medias) async {
    FormData formData = FormData.fromMap({
      ...data.toJson(),
      'hashtags[]': data.hashtags.isEmpty ? [''] : data.hashtags,
    });
    for (File media in medias) {
      formData.files.addAll([
        MapEntry(
            "medias",
            await MultipartFile.fromFile(media.path,
                filename: "${user.name}_${data.title}_${media.path}")),
      ]);
    }

    return executeRequest<CreatePostResponse>(
      requestFunction: () => dio.post('post/', data: formData),
      successParser: (data) => CreatePostResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetPostResponse>> getPost(String postId) {
    return executeRequest<GetPostResponse>(
      requestFunction: () => dio.get('post/$postId'),
      successParser: (data) => GetPostResponse.fromJson(data),
    );
  }

  Future<ApiResult<LikePostResponse>> likePost(String postId, bool isLiked) {
    return executeRequest<LikePostResponse>(
      requestFunction: () => dio.put('post/$postId/like', data: {'isLiked': isLiked}),
      successParser: (data) => LikePostResponse.fromJson(data),
    );
  }
}
