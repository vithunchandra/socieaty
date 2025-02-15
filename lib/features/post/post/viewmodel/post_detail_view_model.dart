import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post/model/get_post_response.dart';
import 'package:socieaty/features/post/post/model/like_post_response.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/repository/post_repository.dart';
import 'package:socieaty/features/post/post/viewstate/post_detail_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_detail_view_model.g.dart';

@riverpod
Future<Post> getPost(Ref ref, String postId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final result = await postRepository.getPost(postId);
  switch (result) {
    case Success<GetPostResponse>(data: final data):
      return data.post;
    case Error(error: final error):
      throw Exception(error.message);
  }
}

@riverpod
class PostDetailViewModel extends _$PostDetailViewModel {
  late PostRepository _postRepository;
  @override
  PostDetailViewState build({required String postId}) {
    _postRepository = ref.watch(postRepositoryProvider);
    return PostDetailViewState(postId: postId, likeState: IdleState(), comments: -1);
  }

  Future<void> likePost(bool isLiked) async {
    state = state.copyWith(likeState: LoadingState());
    final result = await _postRepository.likePost(state.postId, isLiked);
    switch (result) {
      case Success<LikePostResponse>(data: final data):
        state = state.copyWith(likeState: SuccessState(data: data));
      case Error(error: final error):
        state = state.copyWith(likeState: ErrorState(message: error.message));
    }
  }

  Future<void> setComments(int comments) async {
    state = state.copyWith(comments: comments);
  }
}
