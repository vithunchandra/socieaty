import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginate_post_query.freezed.dart';
part 'paginate_post_query.g.dart';

@freezed
class PaginatePostQuery with _$PaginatePostQuery {
  const factory PaginatePostQuery({
    @Default(0) int offset,
    @Default(5) int limit,
    String? authorId,
  }) = _PaginatePostQuery;

  factory PaginatePostQuery.fromJson(Map<String, dynamic> json) => _$PaginatePostQueryFromJson(json);
}
