import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/enum/restaurant_verification_status_enum.dart';

part 'update_restaurant_data_request.freezed.dart';
part 'update_restaurant_data_request.g.dart';

@freezed
class UpdateRestaurantDataRequest with _$UpdateRestaurantDataRequest {
  const factory UpdateRestaurantDataRequest({
    @Default(null) String? name,
    @Default(null) String? phoneNumber,
    @Default(0) int openTime,
    @Default(0) int closeTime,
    @Default(null) BankEnum? payoutBank,
    @Default(null) String? accountNumber,
    @Default([]) List<int> themes,
    @LatLngConverter() @Default(null) LatLng? address,
    @RestaurantVerificationStatusConverter()
    required RestaurantVerificationStatus verificationStatus,
  }) = _UpdateRestaurantDataRequest;

  factory UpdateRestaurantDataRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRestaurantDataRequestFromJson(json);
}
