import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/livestream/model/delete_livestream_room_response.dart';
import 'package:socieaty/features/livestream/model/get_livestream_comments_response.dart';
import 'package:socieaty/features/livestream/model/get_livestream_likes_response.dart';
import 'package:socieaty/features/livestream/model/get_livestream_rooms_response.dart';
import 'package:socieaty/features/livestream/model/join_livestream_response.dart';
import 'package:socieaty/features/livestream/model/send_livestream_comment_response.dart';
import 'package:socieaty/features/livestream/model/send_livestream_like_response.dart';
import 'package:socieaty/features/livestream/model/start_livestream_response.dart';
import 'package:socieaty/features/livestream/viewstate/setup_livestream_form_state.dart';

part 'livestream_repository.g.dart';

@riverpod
LivestreamRepository livestreamRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return LivestreamRepository(
    ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class LivestreamRepository {
  late final Dio _dio;

  LivestreamRepository(Dio dio) {
    _dio = dio;
  }

  Future<ApiResult<StartLivestreamResponse>> startLivestream(SetupLivestreamFormState data) {
    return executeRequest<StartLivestreamResponse>(
      requestFunction: () => _dio.post('livestream/start', data: data.toJson()),
      successParser: (data) => StartLivestreamResponse.fromJson(data),
    );
  }

  Future<ApiResult<JoinLivestreamResponse>> joinLivestream(String roomTitle) {
    return executeRequest<JoinLivestreamResponse>(
      requestFunction: () => _dio.post('livestream/$roomTitle/join'),
      successParser: (data) => JoinLivestreamResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetLivestreamRoomsResponse>> getLivestreamRooms() {
    return executeRequest<GetLivestreamRoomsResponse>(
      requestFunction: () => _dio.get('livestream/'),
      successParser: (data) => GetLivestreamRoomsResponse.fromJson(data),
    );
  }

  Future<ApiResult<SendLivestreamCommentResponse>> sendLivestreamComment(String roomName, String text){
    return executeRequest<SendLivestreamCommentResponse>(
      requestFunction: () => _dio.post('livestream/$roomName/comment', data: {'text': text}),
      successParser: (data) => SendLivestreamCommentResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetLivestreamCommentsResponse>> getLivestreamComments(String roomName){
    return executeRequest<GetLivestreamCommentsResponse>(
      requestFunction: () => _dio.get('livestream/$roomName/comment'),
      successParser: (data) => GetLivestreamCommentsResponse.fromJson(data),
    );
  }

  Future<ApiResult<SendLivestreamLikeResponse>> sendLivestreamLike(String roomName, bool isLiked){
    return executeRequest<SendLivestreamLikeResponse>(
      requestFunction: () => _dio.post('livestream/$roomName/like', data: {'isLiked': isLiked}),
      successParser: (data) => SendLivestreamLikeResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetLivestreamLikesResponse>> getLivestreamLikes(String roomName){
    return executeRequest<GetLivestreamLikesResponse>(
      requestFunction: () => _dio.get('livestream/$roomName/like'),
      successParser: (data) => GetLivestreamLikesResponse.fromJson(data),
    );
  }

  Future<ApiResult<DeleteLivestreamRoomResponse>> deleteLivestreamRoom(String roomName){
    return executeRequest<DeleteLivestreamRoomResponse>(
      requestFunction: () => _dio.delete('livestream/$roomName'),
      successParser: (data) => DeleteLivestreamRoomResponse.fromJson(data),
    );
  }
}
