import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/support-ticket/repository/request/get_support_tickets_request_query.dart';
import 'package:socieaty/features/support-ticket/repository/response/get_support_tickets_response.dart';
import 'package:socieaty/features/support-ticket/repository/support_ticket_repository.dart';

part 'get_support_tickets_provider.g.dart';

@riverpod
Future<GetSupportTicketsResponse> getSupportTickets(Ref ref, GetSupportTicketsRequestQuery query) async {
  final repository = ref.watch(supportTicketRepositoryProvider);
  final result = await repository.getSupportTickets(query);
  switch (result) {
    case Success(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}

