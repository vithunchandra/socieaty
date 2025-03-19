import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';

part 'get_facilities_suggestion_provider.g.dart';

@riverpod
Future<List<String>> getFacilitiesSuggestion(Ref ref, String query) async {
  final repository = ref.watch(restaurantRespositoryProvider);
  final result = await repository.getReservationFacilitiesSuggestion(query);
  switch (result) {
    case Success(data: final data):
      return data.facilities;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
