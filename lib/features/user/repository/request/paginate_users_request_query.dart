import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'paginate_users_request_query.freezed.dart';
part 'paginate_users_request_query.g.dart';

@freezed
class PaginateUsersRequestQuery with _$PaginateUsersRequestQuery {
  const factory PaginateUsersRequestQuery({
    @Default(PaginationQuery()) PaginationQuery paginationQuery,
    String? searchQuery,
    @UserRoleConverter() UserRole? role,
  }) = _PaginateUsersRequestQuery;

  factory PaginateUsersRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$PaginateUsersRequestQueryFromJson(json);
}
