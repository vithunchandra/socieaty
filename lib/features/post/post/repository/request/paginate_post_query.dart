import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'paginate_post_query.freezed.dart';
part 'paginate_post_query.g.dart';

@freezed
class PaginatePostQuery with _$PaginatePostQuery {
  const factory PaginatePostQuery({
    @Default(PaginationQuery()) PaginationQuery paginationQuery,
    String? authorId,
    UserRole? userRole,
  }) = _PaginatePostQuery;

  factory PaginatePostQuery.fromJson(Map<String, dynamic> json) => _$PaginatePostQueryFromJson(json);
}
