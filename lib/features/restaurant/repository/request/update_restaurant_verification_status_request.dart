import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/enum/restaurant_verification_status_enum.dart';

part 'update_restaurant_verification_status_request.freezed.dart';
part 'update_restaurant_verification_status_request.g.dart';

@freezed
class UpdateRestaurantVerificationStatusRequest with _$UpdateRestaurantVerificationStatusRequest {
  const factory UpdateRestaurantVerificationStatusRequest({
    @RestaurantVerificationStatusConverter() required RestaurantVerificationStatus status,
  }) = _UpdateRestaurantVerificationStatusRequest;

  factory UpdateRestaurantVerificationStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRestaurantVerificationStatusRequestFromJson(json);
}
