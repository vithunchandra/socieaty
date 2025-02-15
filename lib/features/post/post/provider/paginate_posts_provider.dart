import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post/model/paginate_post_query.dart';
import 'package:socieaty/features/post/post/repository/post_repository.dart';
import 'package:socieaty/features/post/post/repository/response/paginate_post_response.dart';

part 'paginate_posts_provider.g.dart';

@riverpod
Future<PaginatePostResponse> paginatePosts(Ref ref, PaginatePostQuery query) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final posts = await postRepository.paginatePost(query.offset, query.limit, query.authorId);
  switch (posts) {
    case Success(data: final posts):
      return posts;
    case Error(error: final error):
      throw Exception(error.message);
  }
}

