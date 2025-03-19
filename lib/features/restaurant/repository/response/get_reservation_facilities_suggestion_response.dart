import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_reservation_facilities_suggestion_response.freezed.dart';
part 'get_reservation_facilities_suggestion_response.g.dart';

@freezed
class GetReservationFacilitiesSuggestionResponse with _$GetReservationFacilitiesSuggestionResponse {
  const factory GetReservationFacilitiesSuggestionResponse({
    required List<String> facilities,
  }) = _GetReservationFacilitiesSuggestionResponse;

  factory GetReservationFacilitiesSuggestionResponse.fromJson(Map<String, dynamic> json) => _$GetReservationFacilitiesSuggestionResponseFromJson(json);
}