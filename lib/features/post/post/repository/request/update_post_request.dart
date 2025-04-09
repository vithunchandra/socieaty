import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/converter.dart';

part 'update_post_request.freezed.dart';
part 'update_post_request.g.dart';

@freezed
class UpdatePostRequest with _$UpdatePostRequest {
  const factory UpdatePostRequest({
    @Default(null) String? title,
    @Default(null) String? caption,
    @Default([]) List<String> hashtags,
    @Default([]) List<String> deleteMediaIds,
    @LatLngConverter() @Default(LatLng(0, 0)) LatLng? location,
  }) = _UpdatePostRequest;

  factory UpdatePostRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePostRequestFromJson(json);
}
