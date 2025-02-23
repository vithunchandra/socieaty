import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post/repository/response/get_post_response.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/repository/post_repository.dart';

part 'post_provider.g.dart';

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
