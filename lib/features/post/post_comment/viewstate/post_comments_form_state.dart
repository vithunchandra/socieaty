import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_comments_form_state.freezed.dart';
part 'post_comments_form_state.g.dart';

@freezed
class PostCommentsFormState with _$PostCommentsFormState {
  const factory PostCommentsFormState({required String text}) = _PostCommentsFormState;

  factory PostCommentsFormState.fromJson(Map<String, dynamic> json) => _$PostCommentsFormStateFromJson(json);
}
