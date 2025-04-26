import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'paginate_users_response.freezed.dart';
part 'paginate_users_response.g.dart';

@freezed
class PaginateUsersResponse with _$PaginateUsersResponse {
  const factory PaginateUsersResponse({
    required List<SocieatyUser> users,
    required Pagination pagination,
  }) = _PaginateUsersResponse;

  factory PaginateUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginateUsersResponseFromJson(json);
}
