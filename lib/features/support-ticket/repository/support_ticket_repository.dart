import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/features/support-ticket/repository/request/create_support_ticket_request_form.dart';
import 'package:socieaty/features/support-ticket/repository/request/get_support_tickets_request_query.dart';
import 'package:socieaty/features/support-ticket/repository/response/create_support_ticket_message_response.dart';
import 'package:socieaty/features/support-ticket/repository/response/create_support_ticket_response.dart';
import 'package:socieaty/features/support-ticket/repository/response/get_support_ticket_response.dart';
import 'package:socieaty/features/support-ticket/repository/response/get_support_tickets_response.dart';
import 'package:socieaty/features/support-ticket/repository/response/track_support_message_response.dart';
import 'package:socieaty/features/support-ticket/repository/response/update_support_ticket_response.dart';

part 'support_ticket_repository.g.dart';

@riverpod
SupportTicketRepository supportTicketRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return SupportTicketRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class SupportTicketRepository {
  final Dio _dio;

  SupportTicketRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<CreateSupportTicketResponse>> createSupportTicket(
      CreateSupportTicketRequestForm data) {
    return executeRequest<CreateSupportTicketResponse>(
      requestFunction: () => _dio.post('support-tickets', data: data.toJson()),
      successParser: (data) => CreateSupportTicketResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateSupportTicketResponse>> updateSupportTicket(
    String id,
    SupportTicketStatus status,
  ) {
    return executeRequest<UpdateSupportTicketResponse>(
      requestFunction: () => _dio.put('support-tickets/$id', data: {'status': status.name}),
      successParser: (data) => UpdateSupportTicketResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetSupportTicketsResponse>> getSupportTickets(
    GetSupportTicketsRequestQuery query,
  ) {
    final queryData = {
      'paginationQuery': query.paginationQuery.toJson(),
      if (query.userId != null) 'userId': query.userId,
      if (query.searchQuery != null) 'searchQuery': query.searchQuery,
      if (query.status != null) 'status': query.status?.name,
    };
    return executeRequest<GetSupportTicketsResponse>(
      requestFunction: () => _dio.get('support-tickets', queryParameters: queryData),
      successParser: (data) => GetSupportTicketsResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetSupportTicketResponse>> getSupportTicket(String id) {
    return executeRequest<GetSupportTicketResponse>(
      requestFunction: () => _dio.get('support-tickets/$id'),
      successParser: (data) => GetSupportTicketResponse.fromJson(data),
    );
  }

  Future<ApiResult<CreateSupportTicketMessageResponse>> createSupportTicketMessage(
    String id,
    String message,
  ) {
    return executeRequest<CreateSupportTicketMessageResponse>(
      requestFunction: () => _dio.post('support-tickets/$id/messages', data: {'message': message}),
      successParser: (data) => CreateSupportTicketMessageResponse.fromJson(data),
    );
  }

  Future<ApiResult<TrackSupportMessageResponse>> trackSupportTicketMessage(String id) {
    return executeRequest<TrackSupportMessageResponse>(
      requestFunction: () => _dio.get('support-tickets/$id/messages/track'),
      successParser: (data) => TrackSupportMessageResponse.fromJson(data),
    );
  }
}
