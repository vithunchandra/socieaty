import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post/repository/post_repository.dart';
import 'package:socieaty/features/post/post/repository/response/paginate_post_response.dart';

part 'paginate_posts_provider.g.dart';

@riverpod
Future<PaginatePostResponse> paginatePosts(Ref ref, {int offset = 0, int limit = 5, String authorId = ''}) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final posts = await postRepository.paginatePost(offset, limit, authorId);
  switch (posts) {
    case Success(data: final posts):
      return posts;
    case Error(message: final message):
      throw Exception(message);
  }
}

