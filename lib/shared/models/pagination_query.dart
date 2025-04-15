import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_query.freezed.dart';
part 'pagination_query.g.dart';

@freezed
class PaginationQuery with _$PaginationQuery {
  const factory PaginationQuery({
    @Default(0) int page,
    @Default(5) int pageSize,
  }) = _PaginationQuery;

  factory PaginationQuery.fromJson(Map<String, dynamic> json) => _$PaginationQueryFromJson(json);
}
