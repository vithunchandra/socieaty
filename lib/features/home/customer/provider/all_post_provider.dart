import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/home/customer/repository/home_repository.dart';
import 'package:socieaty/features/post/post/model/post.dart';

part 'all_post_provider.g.dart';

@riverpod
Future<List<Post>> allPost(Ref ref) async {
  final homePostRepository = ref.watch(homeRepositoryProvider);
  final result = await homePostRepository.getAllPost();
  switch (result) {
    case Success(data: final data):
      return data.posts;
    case Error(error: final error):
      throw error.message;
  }
}
