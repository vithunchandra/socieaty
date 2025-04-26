import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/user/repository/request/paginate_users_request_query.dart';
import 'package:socieaty/features/user/repository/response/paginate_users_response.dart';
import 'package:socieaty/features/user/repository/user_repository.dart';

part 'paginate_users_provider.g.dart';

@riverpod
Future<PaginateUsersResponse> paginateUsers(Ref ref, PaginateUsersRequestQuery query) async {
  final result = await ref.watch(userRepositoryProvider).paginateUsers(query);
  switch (result) {
    case Success<PaginateUsersResponse>(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
