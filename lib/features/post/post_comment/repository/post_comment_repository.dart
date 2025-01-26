import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/post/post_comment/model/create_post_comment_response.dart';
import 'package:socieaty/features/post/post_comment/model/get_is_liked_response.dart';
import 'package:socieaty/features/post/post_comment/model/get_post_comments_response.dart';
import 'package:socieaty/features/post/post_comment/model/like_post_comment_response.dart';
import 'package:socieaty/features/post/post_comment/viewstate/post_comments_form_state.dart';

part 'post_comment_repository.g.dart';

@riverpod
PostCommentRepository postCommentRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return PostCommentRepository(
    ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class PostCommentRepository {
  late final Dio _dio;

  PostCommentRepository(Dio dio) {
    _dio = dio;
  }

  Future<ApiResult<CreatePostCommentResponse>> createPostComment(PostCommentsFormState data, String postId) {
    return executeRequest<CreatePostCommentResponse>(
      requestFunction: () => _dio.post('post/$postId/comment', data: data.toJson()),
      successParser: (data) => CreatePostCommentResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetPostCommentsResponse>> getPostComments(String postId) {
    return executeRequest<GetPostCommentsResponse>(
      requestFunction: () => _dio.get('post/$postId/comment'),
      successParser: (data) => GetPostCommentsResponse.fromJson(data),
    );
  }

  Future<ApiResult<LikePostCommentResponse>> likePostComment(String postId, String commentId, bool isLiked) {
    return executeRequest<LikePostCommentResponse>(
      requestFunction: () => _dio.put('post/$postId/comment/$commentId/like', data: {'isLiked': isLiked}),
      successParser: (data) => LikePostCommentResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetIsLikedResponse>> getIsLiked(String postId, String commentId) {
    return executeRequest<GetIsLikedResponse>(
      requestFunction: () => _dio.get('post/$postId/comment/$commentId/is-liked'),
      successParser: (data) => GetIsLikedResponse.fromJson(data),
    );
  }
}
