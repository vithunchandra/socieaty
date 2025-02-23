import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';
import 'package:socieaty/features/livestream/repository/response/send_livestream_like_response.dart';
import 'package:socieaty/shared/view_state.dart';

part 'livestream_view_state.freezed.dart';

@freezed
class LivestreamViewState with _$LivestreamViewState {
  factory LivestreamViewState({
    required String roomName,
    required ViewState<LivestreamComment> comment,
    required ViewState<SendLivestreamLikeResponse> likes,
  }) = _LivestreamViewState;
}
