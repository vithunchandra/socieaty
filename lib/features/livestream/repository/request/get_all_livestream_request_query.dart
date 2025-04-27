import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/converter.dart';

part 'get_all_livestream_request_query.freezed.dart';
part 'get_all_livestream_request_query.g.dart';

@freezed
class GetAllLivestreamRequestQuery with _$GetAllLivestreamRequestQuery {
  const factory GetAllLivestreamRequestQuery({
    String? searchQuery,
    @UserRoleConverter() UserRole? role,
  }) = _GetAllLivestreamRequestQuery;

  factory GetAllLivestreamRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$GetAllLivestreamRequestQueryFromJson(json);
}
